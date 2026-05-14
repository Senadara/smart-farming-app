import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class TambahGejalaScreen extends StatefulWidget {

  const TambahGejalaScreen({super.key});

  @override
  State<TambahGejalaScreen> createState() => _TambahGejalaScreenState();
}

class _TambahGejalaScreenState extends State<TambahGejalaScreen> {

  final _formKey             = GlobalKey<FormState>();
  final _nameController      = TextEditingController();
  File? _image;
  bool _isSubmitting = false;

  Future<void> _onPickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Sumber Foto',
                  style: semibold16.copyWith(color: dark1)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80, // Kompres untuk hemat bandwidth
      maxWidth: 1080,
    );

    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await GejalaPenyakitAyam().createGejalaAyam(
        _nameController.text.trim(),
        _image!,
      );

      if (response['status']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gejala berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan gejala: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Manajemen Penyakit Ayam',
            greeting: 'Tambah Gejala Penyakit Ayam',
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputFieldWidget(
                  key: const Key('nameField'),
                  label: 'Nama Gejala',
                  hint: 'Contoh: Nafsu Makan Berkurang',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama Gejala Tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                
                ImagePickerWidget(
                  label: 'Ilustrasi Gejala Penyakit Ayam',
                  image: _image,
                  onPickImage: _onPickImage,
                ),
                ],
              )
            )
          )
        ),

        bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: grey.withOpacity(0.4), width: 1),
            ),
          ),
          child: CustomButton(
            key: const Key('submitKomoditasButton'),
            onPressed: _isSubmitting ? null : _submitForm,
            buttonText: 'Tambah Gejala',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
            isLoading: _isSubmitting,
          ),
        ),
      ),
    );
  }
}
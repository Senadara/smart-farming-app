import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/model/Penyakit_Ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class TambahPenangananPenyakitAyamScreen extends StatefulWidget {
  final Map<String, dynamic>? penanganan; // null => Tambah, ada => Edit

  const TambahPenangananPenyakitAyamScreen({super.key, this.penanganan});

  @override
  State<TambahPenangananPenyakitAyamScreen> createState() => _TambahPenangananPenyakitAyamState();
}

class _TambahPenangananPenyakitAyamState extends State<TambahPenangananPenyakitAyamScreen> {
  bool _isLoading    = true;
  List<PenyakitAyam> _penyakitList  = [];
  String? _selectedPenyakit;
  final _gejalaService  = GejalaPenyakitAyam();
  final TextEditingController _catatanController = TextEditingController();

  File? _image;
  bool _isSubmitting = false;
  final _formKey             = GlobalKey<FormState>();

  bool get _isEditMode => widget.penanganan != null;

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
      final Map<String, dynamic> response;

      if (_isEditMode) {
        response = await _gejalaService.updatePenangananPenyakitAyam(
          widget.penanganan!['id'],
          _catatanController.text,
          _image,
        );
      } else {
        debugPrint(_selectedPenyakit);
        debugPrint(_catatanController.text);
        debugPrint(_image?.path);
        response = await _gejalaService.createPenangananPenyakitAyam(
            _selectedPenyakit!, _catatanController.text, _image);
        debugPrint("Sudah terkirim");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Penanganan berhasil diperbarui'
                : 'Penanganan penyakit berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Gagal memperbarui penanganan'
                : 'Gagal menambahkan penanganan penyakit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _catatanController.text = widget.penanganan!['penanganan'] ?? '';
      _isLoading = false;
    } else {
      _fetchPenyakit();
    }
  }

  Future<void> _fetchPenyakit() async {
    try {
      final data = await _gejalaService.getPenyakit();
      if (mounted) {
        setState(() => _penyakitList = data);
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDropdownChanged(String? value) {
    if (value == null) return;
    final selected = _penyakitList.firstWhere((p) => p.namaPenyakit == value);
    setState(() {
      _selectedPenyakit = selected.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: Header(
            headerType: HeaderType.back,
            title: 'Manajemen Penyakit Ayam',
            greeting: _isEditMode ? 'Edit Penanganan Penyakit' : 'Tambah Penanganan Penyakit',
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!_isEditMode) ...[  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Pilih Penyakit',
                          style: semibold14.copyWith(color: dark1)),
                      const Spacer(),
                    ],
                  ),
                  DropdownFieldWidget(
                    key: const Key('pilihPenyakit'),
                    hint: 'Pilih penyakit ayam...',
                    label: '',
                    items: _penyakitList
                        .map((item) => item.namaPenyakit)
                        .toList(),
                    selectedValue: _selectedPenyakit != null
                        ? _penyakitList
                            .firstWhere((p) => p.id == _selectedPenyakit)
                            .namaPenyakit
                        : null,
                    onChanged: _onDropdownChanged,
                    validator: (_) => _selectedPenyakit == null
                        ? 'Harap pilih penyakit'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                InputFieldWidget(
                    key: const Key('catatan_ternak'),
                    label: 'Penanganan',
                    hint: 'Deskripsikan kondisi ternak secara singkat...',
                    controller: _catatanController,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Catatan tidak boleh kosong';
                      }
                      if (value.trim().length < 10) {
                        return 'Catatan terlalu singkat (min. 10 karakter)';
                      }
                      return null;
                    },
                  ),

                SizedBox(height: 36,),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Foto Obat-obatan', style: bold16),
                    const SizedBox(height: 4),
                    Text(
                      'Opsional – Tambahkan foto untuk memperjelas laporan',
                      style: regular14.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      label: '',
                      image: _image,
                      imageUrl: widget.penanganan?['gambar'],
                      onPickImage: _onPickImage,
                    ),
                  ],
                ),

              ],
            ),
          ))),

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
            buttonText: _isEditMode ? 'Simpan Perubahan' : 'Tambah Penanganan',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
            isLoading: _isSubmitting,
          ),
        ),
      )
    );
  }
}
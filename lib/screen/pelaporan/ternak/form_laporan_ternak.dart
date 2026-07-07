import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/date_picker_field.dart';
import 'package:smart_farming_app/widget/diagnosis_card.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/status_penanganan_toggle.dart';

class FormLaporanTernak extends StatefulWidget {
  final String greeting;
  final String tipe;
  final int step;
  final Map<String, dynamic> data;

  const FormLaporanTernak({
    super.key,
    required this.greeting,
    required this.tipe,
    required this.step,
    required this.data,
  });

  @override
  State<FormLaporanTernak> createState() => _FormLaporanTernakState();
}

class _FormLaporanTernakState extends State<FormLaporanTernak> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _catatanController = TextEditingController();
  final ImageService _imageService = ImageService();
  final LaporanService _laporanService = LaporanService();

  File? _image;
  String? _selectedDate;
  StatusPenanganan _statusPenanganan = StatusPenanganan.belumDitangani;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

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
    if (_selectedDate == null || _selectedDate!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Tanggal kejadian wajib diisi'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Validasi semua field dalam Form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final gejalaList = widget.data['gejala'] as List<dynamic>? ?? [];
      final imageUrl = await _imageService.uploadImage(_image!);

      final formData = {
        'unitBudidayaId': widget.data['unitBudidaya']?['id'] ?? '',
        'objekBudidayaIds':
            (widget.data['selectedAyamIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        'tipe': widget.tipe,
        'judul': widget.data['judul'] ?? 'Laporan Sakit',
        'gambar': imageUrl['data'],
        'catatan': _catatanController.text.trim(),
        'status': _statusPenanganan == StatusPenanganan.sudahDitangani ? '1' : '0',
        'sakit': {
          'penyakitAyamId': widget.data['penyakitId'] ?? widget.data['id'] ?? '',
          'gejala': (widget.data['selectedGejalaIds'] as List<String>?)
                  ?.map((id) => {'id': id})
                  .toList() ??
              [],
        },
      };

      debugPrint('Form Data: $formData');

      final response = await _laporanService.createLaporanAyamSakit(formData);

      debugPrint('Form submitted: $response');

      if (response['status']) {
        if (mounted) {
          context.pushReplacement('/laporan-berhasil',
            extra: {
              'title': 'Laporan Berhasil',
              'message': 'Laporan penyakit ayam berhasil dikirim',
            });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim laporan: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          title: Header(
            headerType: HeaderType.back,
            title: 'Menu Pelaporan',
            greeting: widget.greeting,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu diagnosis
              Builder(builder: (context) {
                debugPrint('[FormLaporanTernak] selectedAyamLabels: ${widget.data['selectedAyamLabels']}');
                return DiagnosisCard(
                  namaPenyakit: widget.data['namaPenyakit'] ?? 'Tidak Diketahui',
                  gejala: widget.data['gejala'] as List<dynamic>? ?? [],
                  selectedAyamIds: (widget.data['selectedAyamLabels'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ?? [],
                );
              }),

              const SizedBox(height: 4),

              // Tanggal Kejadian
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                
                child: DatePickerField(
                  label: 'Tanggal Kejadian',
                  isRequired: true,
                  onChanged: (value) => setState(() => _selectedDate = value),
                ),
              ),

              const SizedBox(height: 16),

              // Status Penanganan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Status Penanganan', style: bold16.copyWith(color: dark1)),
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: bold16.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StatusPenangananToggle(
                      onChanged: (value) =>
                          setState(() => _statusPenanganan = value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Foto Kondisi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Foto Kondisi Ayam', style: bold16),
                    const SizedBox(height: 4),
                    Text(
                      'Opsional – Tambahkan foto untuk memperjelas laporan',
                      style: regular14.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      label: 'Foto kondisi ayam',
                      image: _image,
                      onPickImage: _onPickImage,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Catatan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InputFieldWidget(
                  key: const Key('catatan_ternak'),
                  label: 'Catatan',
                  hint: 'Deskripsikan kondisi ternak secara singkat...',
                  controller: _catatanController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Catatan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Keterangan wajib
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '* Wajib diisi',
                  style: regular14.copyWith(color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: CustomButton(
            key: const Key('kirim_laporan_ternak'),
            onPressed: _isSubmitting ? null : _submitForm,
            buttonText: _isSubmitting ? 'Mengirim...' : 'Kirim Laporan',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/Penyakit_Ayam.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/laporan_berhasil_screen.dart';
import 'package:smart_farming_app/model/gejala_model.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/tag_input_field.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_gejala_screen.dart';

class TambahPenyakitAyamScreen extends StatefulWidget {
  final PenyakitAyam? penyakit; // null => mode Tambah, ada => mode Edit

  const TambahPenyakitAyamScreen({super.key, this.penyakit});

  @override
  State<TambahPenyakitAyamScreen> createState() =>
      _TambahPenyakitAyamScreenState();
}

class _TambahPenyakitAyamScreenState extends State<TambahPenyakitAyamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gejalaService = GejalaPenyakitAyam();

  List<GejalaModel> _gejalaList = [];
  List<String> _selectedGejalaNames = [];
  final Map<String, TextEditingController> _bobotControllers = {};

  bool _isLoading = true;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.penyakit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.penyakit!.namaPenyakit;
      _selectedGejalaNames = List<String>.from(widget.penyakit!.namaGejalaList);
    }
    _fetchGejala();
  }

  Future<void> _fetchGejala() async {
    try {
      final data = await _gejalaService.getGejala();
      if (mounted) {
        setState(() {
          _gejalaList = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDropdownChanged(String? value) {
    if (value == null) return;

    if (_selectedGejalaNames.contains(value)) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('"$value" sudah ada dalam daftar gejala',
                    style: regular14.copyWith(color: Colors.white)),
              ),
            ]),
            backgroundColor: dark1,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }

    setState(() => _selectedGejalaNames.add(value));
  }

  /// Navigasi ke layar tambah gejala, lalu refresh list saat kembali.
  Future<void> _navigateToTambahGejala() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TambahGejalaScreen()),
    );
    setState(() => _isLoading = true);
    await _fetchGejala();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedGejalaNames.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text('Pilih minimal satu gejala',
                  style: regular14.copyWith(color: Colors.white)),
            ]),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      return;
    }

    final gejalaWithBobot = _gejalaList
        .where((g) => _selectedGejalaNames.contains(g.namaGejala))
        .map((g) {
          final bobotText = _bobotControllers[g.namaGejala]?.text.trim() ?? '0.90';
          final bobot = double.tryParse(bobotText) ?? 0.90;
          return {'id': g.id, 'bobot': bobot};
        })
        .toList();

    setState(() => _isSubmitting = true);
    try {
      final Map<String, dynamic> response;

      if (_isEditMode) {
        response = await _gejalaService.updatePenyakitAyam(
            widget.penyakit!.id, _nameController.text.trim(), gejalaWithBobot);
      } else {
        response = await _gejalaService.createPenyakitAyam(
            _nameController.text.trim(), gejalaWithBobot);
      }

      if (response['status']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode
                  ? 'Penyakit Ayam Berhasil Diperbarui'
                  : 'Penyakit Ayam Berhasil Ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception(response['message'] ??
            (_isEditMode
                ? 'Gagal memperbarui penyakit'
                : 'Gagal menambahkan penyakit'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                  _isEditMode
                      ? 'Gagal memperbarui penyakit: $e'
                      : 'Gagal menambahkan penyakit: $e',
                  style: regular14.copyWith(color: Colors.white)),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _bobotControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
            title: 'Manajemen Penyakit Ayam',
            greeting:
                _isEditMode ? 'Edit Penyakit Ayam' : 'Tambah Penyakit Ayam',
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
                  label: 'Nama Penyakit Ayam',
                  hint: 'Contoh: Flu Burung',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama penyakit tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pilih Gejala',
                        style: semibold14.copyWith(color: dark1)),
                    GestureDetector(
                      onTap: _navigateToTambahGejala,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline_rounded,
                              size: 14, color: green1),
                          const SizedBox(width: 4),
                          Text('Tambah Gejala Baru',
                              style: medium12.copyWith(color: green1)),
                        ],
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 8),

                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _gejalaList.isEmpty
                        ? _EmptyGejalaState(onTambah: _navigateToTambahGejala)
                        : DropdownFieldWidget(
                            key: ValueKey('pilihGejala_${_selectedGejalaNames.length}'),
                            hint: 'Cari dan tambah gejala...',
                            label: '',
                            items: _gejalaList
                                .map((item) => item.namaGejala)
                                .where((name) => !_selectedGejalaNames.contains(name))
                                .toList(),
                            selectedValue: null,
                            onChanged: _onDropdownChanged,
                            validator: (_) => _selectedGejalaNames.isEmpty
                                ? 'Pilih minimal satu gejala'
                                : null,
                          ),

                const SizedBox(height: 20),

                // TagInputField(
                //   label: 'Gejala Terpilih',
                //   placeholder: 'Pilih gejala dari dropdown di atas...',
                //   tags: _selectedGejalaNames,
                //   showClearAll: _selectedGejalaNames.length > 1,
                //   onTagsChanged: (updated) =>
                //       setState(() => _selectedGejalaNames = updated),
                // ),

                 Text("Gejala Terpilih: ",
                     style: semibold14.copyWith(color: dark1)),
                 const SizedBox(height: 12),
 
                 if (_selectedGejalaNames.isNotEmpty) ...[
                   // Header Row untuk Label Kolom
                   Row(
                     children: [
                       Expanded(
                         child: Text(
                           "Nama Gejala",
                           style: medium12.copyWith(color: dark3),
                         ),
                       ),
                       const SizedBox(width: 8),
                       SizedBox(
                         width: 80,
                         child: Text(
                           "Bobot",
                           style: medium12.copyWith(color: dark3),
                         ),
                       ),
                       const SizedBox(width: 32), // Menyelaraskan dengan lebar tombol hapus
                     ],
                   ),
                   const SizedBox(height: 6),
 
                   // List Gejala yang terpilih
                   ..._selectedGejalaNames.map((gejala) {
                     final controller = _bobotControllers.putIfAbsent(
                       gejala,
                       () => TextEditingController(),
                     );
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           Expanded(
                             child: Container(
                               height: 48,
                               padding: const EdgeInsets.symmetric(horizontal: 12),
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.grey.shade300, width: 1),
                               ),
                               alignment: Alignment.centerLeft,
                               child: Text(
                                 gejala,
                                 style: medium14.copyWith(color: dark1),
                               ),
                             ),
                           ),
                           const SizedBox(width: 8),
                           SizedBox(
                             width: 80,
                             height: 48,
                             child: TextFormField(
                               controller: controller,
                               keyboardType: const TextInputType.numberWithOptions(decimal: true),
                               style: medium14.copyWith(color: dark1),
                               decoration: InputDecoration(
                                 hintText: "0.90",
                                 hintStyle: medium14.copyWith(color: grey),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                 filled: true,
                                 fillColor: Colors.white,
                                 border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(8),
                                   borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                 ),
                                 enabledBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(8),
                                   borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                 ),
                               ),
                             ),
                           ),
                           const SizedBox(width: 8),
                           GestureDetector(
                             onTap: () {
                               setState(() {
                                 _selectedGejalaNames.remove(gejala);
                                 _bobotControllers[gejala]?.dispose();
                                 _bobotControllers.remove(gejala);
                               });
                             },
                             child: const SizedBox(
                               width: 24,
                               height: 48,
                               child: Icon(Icons.close, color: Colors.red, size: 20),
                             ),
                           ),
                         ],
                       ),
                     );
                   }),
                 ] else ...[
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: const Color(0xFFFAFAFA),
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: Colors.grey.shade200, width: 1),
                     ),
                     child: Text(
                       "Belum ada gejala terpilih",
                       style: regular14.copyWith(color: dark3),
                     ),
                   ),
                 ],


                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
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
            buttonText: _isEditMode ? 'Simpan Perubahan' : 'Tambah Penyakit',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
            isLoading: _isSubmitting,
          ),
        ),
      ),
    );
  }
}

class _EmptyGejalaState extends StatelessWidget {
  final VoidCallback onTambah;
  const _EmptyGejalaState({required this.onTambah});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 36, color: dark3),
          const SizedBox(height: 8),
          Text('Belum ada gejala tersedia',
              style: medium14.copyWith(color: dark3)),
          const SizedBox(height: 4),
          Text('Tambahkan gejala terlebih dahulu',
              style: regular12.copyWith(color: dark3)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTambah,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: green1.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: green1.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: green1),
                  const SizedBox(width: 6),
                  Text('Tambah Gejala Baru',
                      style: medium14.copyWith(color: green1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

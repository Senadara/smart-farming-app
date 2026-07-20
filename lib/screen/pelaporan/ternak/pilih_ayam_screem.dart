import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/model/ayam.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_menu_laporan_sakit.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/objek_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/info_ayam.dart';
import 'package:smart_farming_app/widget/kandang_layout_widget.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PilihAyamScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PilihAyamScreen({
    super.key,
    this.data,
    required this.greeting,
    required this.tipe,
    required this.step,
  });

  @override
  State<PilihAyamScreen> createState() => _PilihAyamScreenState();
}

class _PilihAyamScreenState extends State<PilihAyamScreen> {
  final ObjekBudidayaService _objekBudidayaService = ObjekBudidayaService();
  final LaporanService _laporanService = LaporanService();

  List<dynamic> _listTernak = [];
  final List<Map<String, dynamic>> _selectedTernak = [];
  List<String> _selectedAyamIds =
      []; // ID ayam yang dipilih dari layout kandang
  List<String> _selectedAyamLabels =
      []; // Kode petak ayam yang dipilih (misal A1, B2)

  // Map<objekBudidayaId, statusPenanganan> dari riwayat laporan sakit
  Map<String, String> _sickIds = {};

  // Layout kandang dibuat setelah fetch API selesai
  List<List<Ayam>> _ayamLayout = [];
  final GlobalKey<KandangLayoutWidgetState> _kandangLayoutKey = GlobalKey<KandangLayoutWidgetState>();

  Future<void> _fetchData() async {
    try {
      final unitBudidaya = widget.data?['unitBudidaya'];
      final String unitId = unitBudidaya?['id'] ?? '';
      final int kapasitas = unitBudidaya?['kapasitas'] ?? 0;

      // Fetch data ayam dan riwayat sakit secara paralel
      final results = await Future.wait([
        _objekBudidayaService.getObjekBudidayaByUnitBudidaya(unitId),
        _laporanService.getRiwayatLaporanAyamSakit(unitId),
      ]);

      final response = results[0];
      final riwayatResponse = results[1];

      // Bangun map sickIds dari riwayat laporan: {objekBudidayaId: status}
      final Map<String, String> sickIds = {};
      if (riwayatResponse['status'] == true) {
        final List<dynamic> riwayat = riwayatResponse['data'] ?? [];
        for (final laporan in riwayat) {
          final List<dynamic> objekList = laporan['objekBudidayaList'] ?? [];
          final String status = laporan['Sakit']?['status'] ?? '';
          for (final objek in objekList) {
            final String id = objek['id']?.toString() ?? '';
            if (id.isNotEmpty) {
              // Prioritas status penyakit (semakin butuh perhatian, semakin diprioritaskan untuk dioverwrite)
              // 1. Belum Ditangani
              // 2. Pemantauan
              // 3. Sembuh / Sudah ditangani
              final currentStatus = sickIds[id];

              if (currentStatus == null) {
                sickIds[id] = status;
              } else if (currentStatus == 'Sembuh' ||
                  currentStatus == 'Sudah ditangani') {
                sickIds[id] =
                    status; // Overwrite sembuh dengan status apapun yang baru ditemukan (jika ayam ternyata sakit lagi)
              } else if (currentStatus == 'Pemantauan' &&
                  (status == 'Belum Ditangani' ||
                      status == 'Belum ditangani' ||
                      status.isEmpty)) {
                sickIds[id] =
                    status; // Overwrite pemantauan jika ada yang belum ditangani
              }
            }
          }
        }
      }

      if (response['status']) {
        setState(() {
          _listTernak = response['data'] ?? [];
          _sickIds = sickIds;
          _ayamLayout = generateAyamLayoutFromApi(
            dataApi: _listTernak,
            kapasitas: kapasitas,
            sickIds: _sickIds,
          );
        });
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _submitForm() async {
    if (_selectedAyamIds.isEmpty) {
      showAppToast(
        context,
        'Harap pilih setidaknya satu ternak untuk melanjutkan.',
        isError: true,
      );
      return;
    }

    final updatedData = Map<String, dynamic>.from(widget.data ?? {});
    updatedData['selectedAyamIds'] = _selectedAyamIds;
    updatedData['selectedAyamLabels'] = _selectedAyamLabels;

    final selectedObjek = _listTernak
        .where((item) => _selectedAyamIds.contains(item['id']?.toString() ?? ''))
        .map((item) => {
              'id': item['id'],
              'name': item['namaId'] ?? item['id']?.toString(),
            })
        .toList();
    updatedData['objekBudidaya'] = selectedObjek;

    if (widget.tipe == "panen") {
      final unitName = widget.data?['unitBudidaya']?['name'] ?? '';
      final defaultJudul = 'Laporan Panen $unitName Cepat';
      final judulController = TextEditingController(text: defaultJudul);
      final jumlahController = TextEditingController(text: _selectedAyamIds.length.toString());
      final beratController = TextEditingController();
      final tanggalController = TextEditingController();
      DateTime selectedDate = DateTime.now();
      tanggalController.text =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      final formKey = GlobalKey<FormState>();

      print('[DEBUG] PilihAyamScreen: Showing dialog Panen. Selected Ayam: $_selectedAyamIds, Labels: $_selectedAyamLabels');
      showDialog(
        context: context,
        builder: (dialogCtx) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Simpan Hasil Panen',
                        style: bold18.copyWith(color: dark1),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masukkan detail hasil panen untuk petak kandang yang dipilih.',
                        style: regular12.copyWith(color: dark3),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            selectedDate = picked;
                            tanggalController.text =
                                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                          }
                        },
                        child: AbsorbPointer(
                          child: InputFieldWidget(
                            label: 'Tanggal Panen',
                            hint: 'Pilih tanggal panen',
                            controller: tanggalController,
                            isDisabled: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Tanggal panen tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      InputFieldWidget(
                        label: 'Judul Laporan',
                        hint: 'Masukkan judul laporan',
                        controller: judulController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul laporan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      InputFieldWidget(
                        label: 'Jumlah',
                        hint: 'Masukkan jumlah',
                        controller: jumlahController,
                        keyboardType: TextInputType.number,
                        isDisabled: true,
                        isGrayed: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Jumlah harus berupa angka bulat';
                          }
                          return null;
                        },
                      ),
                      InputFieldWidget(
                        label: 'Berat (kg)',
                        hint: 'Masukkan berat',
                        controller: beratController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Berat tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Berat harus berupa angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Batal',
                                style: semibold14.copyWith(color: dark2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  final judul = judulController.text.trim();
                                  final jumlah = int.parse(jumlahController.text.trim());
                                  final berat = double.parse(beratController.text.trim());

                                  Navigator.pop(dialogCtx); // Close dialog

                                  // Show loading
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  try {
                                    final reqBody = {
                                      "unitBudidayaId": widget.data?['unitBudidaya']?['id'],
                                      "judul": judul,
                                      "createdAt": selectedDate.toUtc().toIso8601String(),
                                      "panen": {
                                        "komoditasId": widget.data?['komoditas']?['id'],
                                        "jumlah": jumlah,
                                        "berat": berat,
                                        "jumlahHewan": 0,
                                      },
                                      "detailPanen": _selectedAyamIds,
                                    };

                                    final response = await _laporanService.createLaporanPanenSimple(reqBody);

                                    if (context.mounted) {
                                      Navigator.pop(context); // Close loading
                                    }

                                    if (response['status'] == true) {
                                      if (context.mounted) {
                                        showAppToast(
                                          context,
                                          'Laporan panen berhasil disimpan!',
                                          isError: false,
                                        );
                                        context.go('/laporan-berhasil', extra: {
                                          'title': 'Laporan Panen Berhasil',
                                          'message': 'Laporan hasil panen berhasil disimpan.',
                                        });
                                      }
                                    } else {
                                      if (context.mounted) {
                                        showAppToast(
                                          context,
                                          'Gagal menyimpan laporan: ${response['message']}',
                                          isError: true,
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context); // Close loading
                                      showAppToast(
                                        context,
                                        'Terjadi kesalahan: $e',
                                        isError: true,
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Simpan',
                                style: semibold14.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      context.push('/pilih-menu-laporan-sakit',
          extra: PilihMenuLaporanSakit(
            greeting: widget.greeting,
            data: updatedData,
            tipe: widget.tipe,
            step: widget.step + 1,
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Header
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

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BannerWidget(
              title: 'Step ${widget.step} - Pilih Ternak',
              subtitle: 'Pilih ternak yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _kandangLayoutKey.currentState?.selectAll();
                    },
                    icon: Icon(Icons.select_all, color: green1),
                    label: Text(
                      'Pilih Semua',
                      style: semibold14.copyWith(color: green1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      _kandangLayoutKey.currentState?.deselectAll();
                    },
                    icon: const Icon(Icons.deselect, color: Colors.red),
                    label: Text(
                      'Batal Pilih Semua',
                      style: semibold14.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                child: KandangLayoutWidget(
                  key: _kandangLayoutKey,
                  ayamLayout: _ayamLayout,
                  onSelectionChanged: (ids, ayamList) {
                    setState(() {
                      _selectedAyamIds = ids;
                      _selectedAyamLabels = ayamList
                          .map((a) => a.displayLabel ?? '')
                          .where((label) => label.isNotEmpty)
                          .toList();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Button Next
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const InfoAyam(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                  onPressed: () {
                    _submitForm();
                  },
                  buttonText: 'Selanjutnya',
                  backgroundColor: green1,
                  textStyle: semibold16.copyWith(color: white),
                  key: const Key('next_button_pilih_ternak')),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/form_laporan_ternak.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/diagnosis_card.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/treatment_recommendations.dart';

class HasilDiagnosisPenyakitScreen extends StatefulWidget {
  final String greeting;
  final String tipe;
  final int step;
  final Map<String, dynamic> data;

  const HasilDiagnosisPenyakitScreen({
    super.key,
    required this.greeting,
    required this.tipe,
    required this.step,
    required this.data,
  });

  @override
  State<HasilDiagnosisPenyakitScreen> createState() =>
      _HasilDiagnosisPenyakitScreenState();
}

class _HasilDiagnosisPenyakitScreenState
    extends State<HasilDiagnosisPenyakitScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateToForm() {
    context.push(
      '/form-laporan-ternak',
      extra: FormLaporanTernak(
        greeting: widget.greeting,
        tipe: widget.tipe,
        step: widget.step + 1,
        data: widget.data,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[Hasil Diagnosa Penyakit] ${widget.data}');
    final cfScore = widget.data['cfScore'] as double?;
    final namaPenyakit =
        widget.data['namaPenyakit'] as String? ?? 'Tidak diketahui';
    final gejala = widget.data['gejala'] as List<dynamic>? ?? [];
    final selectedAyamLabels =
        (widget.data['selectedAyamLabels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];

    debugPrint('[HasilDiagnosa] selectedAyamLabels: $selectedAyamLabels');

    final rawPenanganan = widget.data['penanganan'] as List<dynamic>? ?? [];
    final penangananList = rawPenanganan.map((p) {
      // Mendukung dua format: raw API (key 'penanganan') atau format yang sudah dipetakan (key 'deskripsi')
      return {
        'nama': p['nama'] as String? ?? 'Penanganan',
        'deskripsi':
            p['deskripsi'] as String? ?? p['penanganan'] as String? ?? '',
      };
    }).toList();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu diagnosis (dengan CF score bar)
            DiagnosisCard(
              namaPenyakit: namaPenyakit,
              gejala: gejala,
              cfScore: cfScore,
              selectedAyamIds: selectedAyamLabels,
            ),

            const SizedBox(height: 4),

            // Section rekomendasi penanganan
            TreatmentRecommendations(
              customPenanganan: penangananList,
            ),
          ],
        ),
      ),

      // Tombol navigasi ke form laporan
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: CustomButton(
            key: const Key('next_button_hasil_diagnosis'),
            onPressed: _navigateToForm,
            buttonText: 'Buat Laporan',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
          ),
        ),
      ),
    );
  }
}

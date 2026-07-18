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
            .toList() ??
        [];

    debugPrint('[HasilDiagnosa] selectedAyamLabels: $selectedAyamLabels');

    // ── Penanganan by penyakit ────────────────────────────────────────────
    final rawPenanganan = widget.data['penanganan'] as List<dynamic>? ?? [];
    final penangananList = rawPenanganan.map((p) {
      return {
        'nama': p['nama'] as String? ?? 'Penanganan',
        'deskripsi':
            p['deskripsi'] as String? ?? p['penanganan'] as String? ?? '',
        'gambar': p['gambar'] as String?,
      };
    }).toList();

    // ── Penanganan by gejala (field baru dari API) ─────────────────────────
    final rawPenangananGejala =
        widget.data['penangananGejala'] as List<dynamic>? ?? [];
    final penangananGejalaList = rawPenangananGejala.map((p) {
      // Gunakan nama gejala sebagai judul item penanganan
      final namaGejala = p['gejala'] != null
          ? (p['gejala']['nama_gejala'] as String? ?? '')
          : '';
      return {
        'nama': namaGejala.isNotEmpty ? namaGejala : 'Penanganan Gejala',
        'deskripsi':
            p['deskripsi'] as String? ?? p['penanganan'] as String? ?? '',
        'gambar': p['gambar'] as String?,
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

            // ── Section 1: Penanganan berdasarkan penyakit ─────────────────
            if (penangananList.isNotEmpty)
              TreatmentRecommendations(
                title: 'Penanganan Penyakit',
                customPenanganan: penangananList,
                showDisclaimer: penangananGejalaList.isEmpty,
              ),

            // ── Section 2: Penanganan berdasarkan gejala ───────────────────
            if (penangananGejalaList.isNotEmpty) ...[
              const SizedBox(height: 8),
              // Label pemisah
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 14, color: Colors.orange.shade400),
                          const SizedBox(width: 4),
                          Text(
                            'Berdasarkan Gejala',
                            style: regular12.copyWith(
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                  ],
                ),
              ),
              TreatmentRecommendations(
                title: 'Penanganan per Gejala',
                customPenanganan: penangananGejalaList,
              ),
            ],

            // ── Fallback: keduanya kosong → tampilkan dummy ────────────────
            if (penangananList.isEmpty && penangananGejalaList.isEmpty)
              const TreatmentRecommendations(),
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

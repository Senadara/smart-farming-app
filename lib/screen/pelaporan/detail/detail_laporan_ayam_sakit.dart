import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/diagnosis_card.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/treatment_recommendations.dart';

class DetailLaporanAyamSakit extends StatefulWidget {
  final String? idLaporanAyamSakit;

  const DetailLaporanAyamSakit({super.key, this.idLaporanAyamSakit});

  @override
  State<DetailLaporanAyamSakit> createState() => _DetailLaporanAyamSakitState();
}

class _DetailLaporanAyamSakitState extends State<DetailLaporanAyamSakit> {
  final LaporanService _laporanService = LaporanService();

  bool isLoading = true;
  Map<String, dynamic>? laporanSakit;

  Future<void> fetchData() async {
    try {
      final response =
          await _laporanService.getLaporanAyamSakitById(widget.idLaporanAyamSakit!);

      debugPrint('[Detail Ayam Sakit] $response');
      if (response['status']) {
        setState(() {
          laporanSakit = response['data'];
        });
      } else {
        showAppToast(context, response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
            title: 'Laporan Penyakit',
            greeting: 'Detail Laporan Ayam Sakit',
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : laporanSakit == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          key: const Key('no_data_found'),
                          'Data laporan tidak ditemukan.',
                          style: medium14.copyWith(color: dark2),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          key: const Key('reload_button'),
                          onPressed: fetchData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Muat Ulang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green1,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (laporanSakit?['laporan']?['gambar'] != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ImageBuilder(
                                      url: laporanSakit?['laporan']?['gambar'],
                                      fit: BoxFit.cover)),
                            ),
                          DiagnosisCard(
                            namaPenyakit: laporanSakit?['namaPenyakit']?['nama_penyakit'] ?? '-',
                            gejala: _getGejalaStrings(),
                            cfScore: laporanSakit?['cfScore']?.toDouble(),
                          ),

                          const SizedBox(height: 4),

                          TreatmentRecommendations(
                            customPenanganan: laporanSakit?['penanganan'] as List<dynamic>?,
                          ),

                          const SizedBox(height: 24), 
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  List<String> _getGejalaStrings() {
    final daftar = laporanSakit?['listGejala'] as List?;
    if (daftar == null || daftar.isEmpty) return [];

    List<String> result = [];
    for (var d in daftar) {
      final g = d['nama_gejala'];
      if (g != null && g.toString().isNotEmpty) {
        result.add(g.toString());
      }
    }
    return result;
  }
}
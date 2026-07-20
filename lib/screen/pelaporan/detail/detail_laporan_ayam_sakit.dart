import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/model/Ayam.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/diagnosis_card.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/treatment_recommendations.dart';

// ─── Shared color constants ───────────────────────────────────────────────────
const _kPrimaryGreen = Color(0xFF3A5A3A);
const _kCardBorder = Color(0xFFEDEDED);

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
      final response = await _laporanService
          .getLaporanAyamSakitById(widget.idLaporanAyamSakit!);

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

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  ({String label, Color bg, Color text, IconData icon}) _statusInfo(
      String? status) {
    switch (status) {
      case 'Sembuh':
      case 'Sudah ditangani':
        return (
          label: 'Sembuh',
          bg: const Color(0xFFE6F4EA),
          text: const Color(0xFF2E7D32),
          icon: Icons.check_circle_outline,
        );
      case 'Pemantauan':
        return (
          label: 'Pemantauan',
          bg: const Color(0xFFFFF8E1),
          text: const Color(0xFFF57F17),
          icon: Icons.visibility_outlined,
        );
      default:
        return (
          label: 'Belum Ditangani',
          bg: const Color(0xFFFFEBEE),
          text: const Color(0xFFC62828),
          icon: Icons.priority_high_rounded,
        );
    }
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

  List<String> _getObjekBudidayaLabels() {
    final list = laporanSakit?['objekBudidayaList'] as List?;
    if (list == null || list.isEmpty) return [];

    return list.map((item) {
      final namaId = item['namaId']?.toString() ?? '';
      return getAyamLabelFromNamaId(namaId);
    }).toList();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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
                : RefreshIndicator(
                    color: _kPrimaryGreen,
                    onRefresh: fetchData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Foto laporan
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

                          // Kartu diagnosis
                          DiagnosisCard(
                            key: ValueKey(
                                'diagnosis_${laporanSakit?['objekBudidayaList']?.length ?? 0}'),
                            namaPenyakit: (laporanSakit?['namaPenyakit']?['nama_penyakit'] == null ||
                                    (laporanSakit!['namaPenyakit']!['nama_penyakit'] as String).isEmpty ||
                                    (laporanSakit!['namaPenyakit']!['nama_penyakit'] as String).toLowerCase() == 'unknown')
                                ? (laporanSakit?['laporan']?['judul'] ?? '-')
                                : laporanSakit!['namaPenyakit']['nama_penyakit'],
                            gejala: _getGejalaStrings(),
                            cfScore: laporanSakit?['cfScore']?.toDouble(),
                            selectedAyamIds: _getObjekBudidayaLabels(),
                          ),

                          // Catatan Pelaporan
                          _buildCatatanLaporan(),

                          const SizedBox(height: 16),

                          // Rekomendasi penanganan
                          TreatmentRecommendations(
                            customPenanganan:
                                laporanSakit?['penanganan'] as List<dynamic>?,
                          ),

                          const SizedBox(height: 16),

                          // Status terkini
                          _buildCurrentStatus(),

                          const SizedBox(height: 16),

                          // Riwayat status log
                          _buildStatusLog(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // ── Status Terkini ──────────────────────────────────────────────────────────
  Widget _buildCurrentStatus() {
    final statusStr =
        laporanSakit?['laporan']?['Sakit']?['status'] as String?;
    final info = _statusInfo(statusStr);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(text: 'STATUS SAAT INI'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kCardBorder),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: info.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(info.icon, size: 16, color: info.text),
                ),
                const SizedBox(width: 12),
                Text(
                  info.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: info.text,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: info.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    info.label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: info.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Catatan Pelaporan ───────────────────────────────────────────────────────
  Widget _buildCatatanLaporan() {
    final catatan = laporanSakit?['catatan']?.toString() ??
        laporanSakit?['laporan']?['catatan']?.toString();
    if (catatan == null || catatan.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(text: 'CATATAN PELAPORAN'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kCardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              catatan,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Riwayat Status Log ──────────────────────────────────────────────────────
  Widget _buildStatusLog() {
    final rawLog = (laporanSakit?['statusLog'] as List?) ??
        (laporanSakit?['riwayatStatus'] as List?) ??
        [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionLabel(text: 'RIWAYAT STATUS'),
              if (rawLog.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${rawLog.length}',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600])),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          if (rawLog.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kCardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 16, color: Colors.grey[300]),
                  const SizedBox(width: 8),
                  Text(
                    'Belum ada riwayat update status',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kCardBorder),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rawLog.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 0, thickness: 0.5, color: Colors.grey[100]),
                itemBuilder: (_, i) {
                  final log = rawLog[i] as Map<String, dynamic>;
                  final status = log['status']?.toString() ?? '-';
                  final catatan = log['catatan']?.toString() ?? '';
                  final tanggal = log['createdAt'] ?? log['tanggal'];
                  final petugas = log['petugas']?['name'] ??
                      log['user']?['name'] ??
                      log['updatedBy'] ??
                      '';

                  final info = _statusInfo(status);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline dot + connector
                        Column(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: info.bg,
                                shape: BoxShape.circle,
                              ),
                              child:
                                  Icon(info.icon, size: 14, color: info.text),
                            ),
                            if (i < rawLog.length - 1)
                              Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.grey[200]),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(info.label,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: info.text)),
                                  const Spacer(),
                                  if (tanggal != null)
                                    Text(
                                      _formatDate(tanggal.toString()),
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.black38),
                                    ),
                                ],
                              ),
                              if (petugas.toString().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'oleh $petugas',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black45),
                                ),
                              ],
                              if (catatan.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  child: Text(
                                    catatan,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        height: 1.4),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.black38,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
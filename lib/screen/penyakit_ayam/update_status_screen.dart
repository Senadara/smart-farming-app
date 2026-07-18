import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/model/Ayam.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

const _kPrimaryGreen = Color(0xFF3A5A3A);
const _kTitleDark = Color(0xFF1A2A1A);
const _kTreatmentAccent = Color(0xFF2A6F77);
const _kTreatmentBg = Color(0xFFEAF5F6);
const _kCardBorder = Color(0xFFEDEDED);

class UpdateStatusScreen extends StatefulWidget {
  final String id;
  const UpdateStatusScreen({super.key, required this.id});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  final LaporanService _laporanService = LaporanService();
  final TextEditingController _catatanController = TextEditingController();
  Map<String, dynamic>? _laporan;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchLaporan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _laporanService.getLaporanAyamSakitById(widget.id);
    print("DEBUG: Laporan Result: $result");

    if (!mounted) return;

    if (result['status'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final existing =
          (data['laporan']?['Sakit']?['status'] ?? '') as String;
      setState(() {
        _laporan = data;
        // Map semua varian lama ke nilai baru
        if (existing == 'Sudah ditangani' || existing == 'Sembuh') {
          _selectedStatus = 'Sembuh';
        } else if (existing == 'Pemantauan') {
          _selectedStatus = 'Pemantauan';
        } else if (existing == 'Mati') {
          _selectedStatus = 'Mati';
        } else {
          _selectedStatus = 'Belum Ditangani';
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage =
            result['message']?.toString() ?? 'Gagal memuat laporan';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_selectedStatus == null) {
      _showSnack('Pilih status penanganan terlebih dahulu.', isError: true);
      return;
    }

    final idLaporanSakit =
        _laporan?['laporan']?['Sakit']?['id'] as String? ?? widget.id;

    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{'status': _selectedStatus};
    final catatan = _catatanController.text.trim();
    if (catatan.isNotEmpty) payload['catatan'] = catatan;

    final result = await _laporanService.updateLaporanSakit(
      idLaporanSakit,
      payload,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['status'] == true) {
      _showSnack('Status berhasil diperbarui.');
      Navigator.pop(context, true);
    } else {
      _showSnack(
        'Gagal memperbarui status: ${result['message']?.toString() ?? 'Unknown error'}',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Label posisi kandang dari daftar ternak yang dilaporkan, mis. "B5, C5".
  /// Fallback ke judul generik jika data kandang tidak tersedia.
  /// (Tidak diubah sesuai permintaan.)
  String _kandangLabel(Map<String, dynamic> laporan, List<dynamic> objekList) {
    if (objekList.isEmpty) return laporan['judul'] ?? 'Laporan Sakit';

    final labels = objekList
        .map((item) => getAyamLabelFromNamaId(item['namaId']?.toString() ?? ''))
        .where((label) => label.isNotEmpty)
        .toList();

    return labels.isEmpty ? (laporan['judul'] ?? 'Laporan Sakit') : labels.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
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
            title: 'Update Status Ayam Sakit',
            greeting: 'Update status laporan',
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _isLoading || _errorMessage != null
          ? null
          : SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: CustomButton(
                  key: const Key('kirim_laporan_ternak'),
                  onPressed: _isSubmitting ? null : _submitForm,
                  buttonText: _isSubmitting ? 'Mengirim...' : 'Update Status',
                  backgroundColor: green1,
                  textStyle: semibold16.copyWith(color: white),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _kPrimaryGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red[200]),
              const SizedBox(height: 12),
              const Text(
                'Gagal memuat laporan',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchLaporan,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Coba lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final laporan = _laporan!['laporan'] as Map<String, dynamic>;
    final namaPenyakit = _laporan!['namaPenyakit'] as Map<String, dynamic>?;
    final listGejala = (_laporan!['listGejala'] as List?) ?? [];
    final objekList = (_laporan!['objekBudidayaList'] as List?) ?? [];
    final penangananList = (_laporan!['penanganan'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDiagnosisCard(laporan, namaPenyakit, objekList),
          const SizedBox(height: 16),
          _buildStatusSection(),
          const SizedBox(height: 16),
          if (penangananList.isNotEmpty) ...[
            _buildTreatmentSection(penangananList, namaPenyakit),
            const SizedBox(height: 16),
          ],
          _buildGejalaSection(listGejala),
          const SizedBox(height: 16),
          _buildStatusLog(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      return DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  // ---------------------------------------------------------------------
  // DIAGNOSIS CARD — gambar lebih besar + info diagnosis lebih menonjol
  // ---------------------------------------------------------------------
  Widget _buildDiagnosisCard(
    Map<String, dynamic> laporan,
    Map<String, dynamic>? namaPenyakit,
    List<dynamic> objekList,
  ) {
    final kandangLabel = _kandangLabel(laporan, objekList);
    final catatan = (laporan['catatan'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar full width dengan overlay info tanggal & jumlah ekor
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 140,
                child: ImageBuilder(
                  url: laporan['gambar'] ?? '',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          kandangLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (objekList.length > 1) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${objekList.length} ekor',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 10, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(laporan['createdAt']),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Info diagnosis
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.coronavirus_outlined,
                          size: 16, color: Color(0xFF791F1F)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diagnosis',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black38,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            namaPenyakit?['nama_penyakit'] ??
                                'Diagnosis belum tersedia',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kTitleDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (catatan.isNotEmpty && catatan != '-') ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sticky_note_2_outlined,
                            size: 13, color: Colors.black38),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            catatan,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // STATUS SECTION
  // ---------------------------------------------------------------------
  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'STATUS PENANGANAN'),
        const SizedBox(height: 6),
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih status penanganan saat ini untuk laporan ini.',
                style: TextStyle(
                    fontSize: 13, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 12),
              _StatusPill(
                label: 'Belum Ditangani',
                subtitle: 'Ayam belum mendapat penanganan',
                badge: 'Perlu tindakan',
                badgeBg: const Color(0xFFFCEBEB),
                badgeText: const Color(0xFF791F1F),
                badgeIcon: Icons.priority_high_rounded,
                activeColor: const Color(0xFFE24B4A),
                activeBg: const Color(0xFFFCEBEB),
                isSelected: _selectedStatus == 'Belum Ditangani',
                onTap: () =>
                    setState(() => _selectedStatus = 'Belum Ditangani'),
              ),
              const SizedBox(height: 8),
              _StatusPill(
                label: 'Pemantauan',
                subtitle: 'Ayam sedang dalam pemantauan kondisi',
                badge: 'Dipantau',
                badgeBg: const Color(0xFFFFF8E1),
                badgeText: const Color(0xFFF57F17),
                badgeIcon: Icons.visibility_outlined,
                activeColor: const Color(0xFFF57F17),
                activeBg: const Color(0xFFFFF8E1),
                isSelected: _selectedStatus == 'Pemantauan',
                onTap: () =>
                    setState(() => _selectedStatus = 'Pemantauan'),
              ),
              const SizedBox(height: 8),
              _StatusPill(
                label: 'Sembuh',
                subtitle: 'Ayam telah pulih dan kondisi normal',
                badge: 'Sembuh',
                badgeBg: const Color(0xFFEAF3DE),
                badgeText: const Color(0xFF27500A),
                badgeIcon: Icons.check_circle_outline_rounded,
                activeColor: _kPrimaryGreen,
                activeBg: const Color(0xFFEAF3DE),
                isSelected: _selectedStatus == 'Sembuh',
                onTap: () =>
                    setState(() => _selectedStatus = 'Sembuh'),
              ),
              const SizedBox(height: 8),
              _StatusPill(
                label: 'Mati',
                subtitle: 'Ayam telah mati',
                badge: 'Mati',
                badgeBg: const Color(0xFFFCEBEB),
                badgeText: const Color(0xFF791F1F),
                badgeIcon: Icons.cancel_outlined,
                activeColor: const Color(0xFFC62828),
                activeBg: const Color(0xFFFCEBEB),
                isSelected: _selectedStatus == 'Mati',
                onTap: () =>
                    setState(() => _selectedStatus = 'Mati'),
              ),
              if (_selectedStatus == 'Belum Ditangani') ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kTreatmentBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 14, color: _kTreatmentAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Lihat rekomendasi penanganan di bawah sebelum mengambil tindakan.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _kTreatmentAccent.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // ── Catatan opsional ──────────────────────────────────────
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 12),
              const Text(
                'Catatan (opsional)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.2),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _catatanController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan kondisi ayam hari ini...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _kPrimaryGreen, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // STATUS LOG / RIWAYAT
  // ---------------------------------------------------------------------
  Widget _buildStatusLog() {
    // Data riwayat dari API — key 'statusLog' atau 'riwayatStatus'
    final rawLog = (_laporan?['statusLog'] as List?) ??
        (_laporan?['riwayatStatus'] as List?) ??
        [];

    if (rawLog.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(text: 'RIWAYAT STATUS'),
          const SizedBox(height: 6),
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
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionLabel(text: 'RIWAYAT STATUS'),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
        ),
        const SizedBox(height: 6),
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

              Color statusColor;
              IconData statusIcon;
              if (status == 'Sembuh' || status == 'Sudah ditangani') {
                statusColor = const Color(0xFF2E7D32);
                statusIcon = Icons.check_circle_outline;
              } else if (status == 'Pemantauan') {
                statusColor = const Color(0xFFF57F17);
                statusIcon = Icons.visibility_outlined;
              } else if (status == 'Mati') {
                statusColor = const Color(0xFFC62828);
                statusIcon = Icons.cancel_outlined;
              } else {
                statusColor = const Color(0xFFC62828);
                statusIcon = Icons.priority_high_rounded;
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dot
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon,
                              size: 14, color: statusColor),
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
                              Text(status,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor)),
                              const Spacer(),
                              if (tanggal != null)
                                Text(
                                  _formatDate(tanggal.toString()),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black38),
                                ),
                            ],
                          ),
                          if (petugas.isNotEmpty) ...[
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
    );
  }

  // ---------------------------------------------------------------------
  // TREATMENT / PENANGANAN SECTION — data baru dari API yang sebelumnya
  // tidak ditampilkan sama sekali di UI.
  // ---------------------------------------------------------------------
  Widget _buildTreatmentSection(
    List penangananList,
    Map<String, dynamic>? namaPenyakit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionLabel(text: 'REKOMENDASI PENANGANAN'),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _kTreatmentBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${penangananList.length}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _kTreatmentAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kTreatmentAccent.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: _kTreatmentBg,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(13)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_information_outlined,
                        size: 15, color: _kTreatmentAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Berdasarkan diagnosis: ${namaPenyakit?['nama_penyakit'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kTreatmentAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: penangananList.length,
                separatorBuilder: (_, __) => Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey[200],
                ),
                itemBuilder: (_, i) {
                  final p = penangananList[i] as Map<String, dynamic>;
                  return _TreatmentTile(
                    text: (p['penanganan'] ?? '-').toString(),
                    imageUrl: p['gambar']?.toString(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGejalaSection(List listGejala) {
    if (listGejala.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionLabel(text: 'GEJALA TERDETEKSI'),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${listGejala.length}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listGejala.length,
            separatorBuilder: (_, __) => Divider(
              height: 0,
              thickness: 0.5,
              color: Colors.grey[200],
            ),
            itemBuilder: (_, i) {
              final g = listGejala[i] as Map<String, dynamic>;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: ImageBuilder(
                          url: g['gambar'] ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        g['nama_gejala'] ?? '-',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _kTitleDark),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Label kecil huruf besar untuk judul setiap section.
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

/// Satu baris rekomendasi penanganan, bisa expand/collapse jika teksnya panjang.
/// Satu baris rekomendasi penanganan, bisa expand/collapse jika teksnya panjang.
class _TreatmentTile extends StatefulWidget {
  final String text;
  final String? imageUrl;

  const _TreatmentTile({required this.text, this.imageUrl});

  @override
  State<_TreatmentTile> createState() => _TreatmentTileState();
}

class _TreatmentTileState extends State<_TreatmentTile> {
  bool _expanded = false;

  /// Fungsi untuk menampilkan pop-up gambar yang bisa di-zoom
  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Fitur zoom menggunakan InteractiveViewer
              InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageBuilder(
                    url: imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Tombol Close
              Positioned(
                top: -15,
                right: -15,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.length > 120;

    return InkWell(
      onTap: isLong ? () => setState(() => _expanded = !_expanded) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: _kTreatmentAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            
            // Thumbnail gambar yang lebih besar & bisa diklik
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _showImagePreview(context, widget.imageUrl!),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 65, // Ukuran diperbesar dari 40 ke 65
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!, width: 0.5),
                        ),
                        child: ImageBuilder(
                          url: widget.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Indikator kecil bahwa gambar bisa di-zoom
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.zoom_out_map,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.text,
                    maxLines: _expanded ? null : 3,
                    overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black87, // Sedikit digelapkan agar lebih kontras
                      height: 1.5,
                    ),
                  ),
                  if (isLong) ...[
                    const SizedBox(height: 6),
                    Text(
                      _expanded ? 'Sembunyikan' : 'Lihat selengkapnya',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _kTreatmentAccent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final String subtitle;
  final String badge;
  final Color badgeBg;
  final Color badgeText;
  final IconData badgeIcon;
  final Color activeColor;
  final Color activeBg;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusPill({
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.badgeBg,
    required this.badgeText,
    required this.badgeIcon,
    required this.activeColor,
    required this.activeBg,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? activeColor.withOpacity(0.4)
                  : Colors.grey[300]!,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? activeColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? activeColor : Colors.grey[350]!,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? activeColor : _kTitleDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 10, color: badgeText),
                    const SizedBox(width: 3),
                    Text(
                      badge,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: badgeText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/laporan_ayam_sakit_model.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/update_status_screen.dart';

class ListLaporanAyamSakitScreen extends StatefulWidget {
  final String unitId;
  const ListLaporanAyamSakitScreen({super.key, required this.unitId});

  @override
  State<ListLaporanAyamSakitScreen> createState() =>
      _ListLaporanAyamSakitScreenState();
}

class _ListLaporanAyamSakitScreenState
    extends State<ListLaporanAyamSakitScreen> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  final LaporanService _laporanService = LaporanService();

  List<LaporanAyamSakit> _laporanList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _laporanService.getRiwayatLaporanAyamSakit(widget.unitId);

    if (!mounted) return;

    if (result['status'] == true) {
      final List<dynamic> data = result['data'] ?? [];
      setState(() {
        _laporanList =
            data.map((e) => LaporanAyamSakit.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message']?.toString() ?? 'Terjadi kesalahan';
        _isLoading = false;
      });
    }
  }

  String _filterStatus = 'semua';

  List<LaporanAyamSakit> get _filtered {
    if (_filterStatus == 'semua') return _laporanList;
    return _laporanList
        .where((l) => l.sakit.status.toLowerCase() == _filterStatus)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Filter bottom-sheet
  // ---------------------------------------------------------------------------
  void _showFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final options = {
              'semua': 'Semua',
              '': 'Belum ditangani',
              'dalam penanganan': 'Dalam penanganan',
              'sembuh': 'Sudah ditangani',
            };
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filter Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...options.entries.map((e) {
                    final selected = _filterStatus == e.key;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selected
                            ? const Color(0xFF3A5A3A)
                            : Colors.grey[400],
                      ),
                      title: Text(e.value,
                          style: TextStyle(
                              fontSize: 14,
                              color: selected
                                  ? const Color(0xFF3A5A3A)
                                  : Colors.black87)),
                      onTap: () {
                        setState(() => _filterStatus = e.key);
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
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
            title: 'Riwayat Ayam Sakit',
            greeting: 'Daftar Laporan Ayam Sakit',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Filter bar ──────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${_filtered.length} laporan',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showFilter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF3A5A3A), width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.filter_list_rounded,
                              size: 16, color: Color(0xFF3A5A3A)),
                          SizedBox(width: 6),
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3A5A3A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF3A5A3A)),
                    )
                  : _errorMessage != null
                      ? _ErrorState(
                          message: _errorMessage!,
                          onRetry: _fetchLaporan,
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF3A5A3A),
                          onRefresh: _fetchLaporan,
                          child: _filtered.isEmpty
                              ? const _EmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 100),
                                  itemCount: _filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, i) =>
                                      _LaporanCard(laporan: _filtered[i]),
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card Widget ─────────────────────────────────────────────────────────────

class _LaporanCard extends StatelessWidget {
  final LaporanAyamSakit laporan;
  const _LaporanCard({required this.laporan});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd-MM-yyyy');
    final status = laporan.statusInfo;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UpdateStatusScreen(id: laporan.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: laporan.gambar.isNotEmpty
                  ? Image.network(
                      laporan.gambar,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _FotoPlaceholder(),
                    )
                  : _FotoPlaceholder(),
            ),

            // ── Info ──────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul + tanggal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            laporan.judul,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fmt.format(laporan.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Diagnosis
                    Row(
                      children: [
                        const Icon(Icons.coronavirus_outlined,
                            size: 13, color: Colors.black38),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            laporan.sakit.diagnosisPenyakit.isEmpty
                                ? 'Diagnosis belum tersedia'
                                : laporan.sakit.diagnosisPenyakit,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Catatan
                    Text(
                      laporan.catatan,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: status.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: status.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _FotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFFD4E4D4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_outlined, size: 28, color: Color(0xFF5A8A5A)),
          SizedBox(height: 4),
          Text(
            'Foto\nAyam',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Color(0xFF5A8A5A)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Tidak ada laporan',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            'Belum ada laporan ayam sakit\nyang tercatat.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red[200]),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A5A3A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

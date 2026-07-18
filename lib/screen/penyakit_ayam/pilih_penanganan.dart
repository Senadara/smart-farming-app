import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/model/Penyakit_Ayam.dart';
import 'package:smart_farming_app/model/gejala_model.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_penanganan_penyakit_ayam.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/header.dart';

class PilihPenanganan extends StatefulWidget {
  final String mode;
  const PilihPenanganan({super.key, this.mode = 'edit'});

  @override
  State<PilihPenanganan> createState() => _PilihPenangananState();
}

class _PilihPenangananState extends State<PilihPenanganan>
    with SingleTickerProviderStateMixin {
  final GejalaPenyakitAyam _service = GejalaPenyakitAyam();
  late TabController _tabController;

  // --- Tab 1: By Penyakit ---
  List<PenyakitAyam> _penyakitList = [];
  bool _loadingPenyakit = true;

  // --- Tab 2: By Gejala ---
  List<GejalaModel> _allGejala = [];
  bool _loadingGejala = true;
  // Cache: gejala_id -> list penanganan
  final Map<String, List<Map<String, dynamic>>> _penangananCache = {};
  // Set gejala_id yang sedang loading
  final Set<String> _loadingGejalaIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPenyakit();
    _fetchAllGejala();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── BY PENYAKIT ──────────────────────────────────────────────────────────

  Future<void> _fetchPenyakit() async {
    try {
      final data = await _service.getPenyakitWithPenanganan();
      data.sort((a, b) {
        final aHas = a.penanganan.isNotEmpty ? 0 : 1;
        final bHas = b.penanganan.isNotEmpty ? 0 : 1;
        if (aHas != bHas) return aHas.compareTo(bHas);
        final aTime = a.penanganan.isNotEmpty && a.penanganan.first['updatedAt'] != null
            ? DateTime.parse(a.penanganan.first['updatedAt'])
            : (a.updatedAt ?? DateTime(0));
        final bTime = b.penanganan.isNotEmpty && b.penanganan.first['updatedAt'] != null
            ? DateTime.parse(b.penanganan.first['updatedAt'])
            : (b.updatedAt ?? DateTime(0));
        return bTime.compareTo(aTime);
      });
      for (var p in data) {
        p.penanganan.sort((a, b) {
          final aT = a['updatedAt'] != null ? DateTime.parse(a['updatedAt']) : DateTime(0);
          final bT = b['updatedAt'] != null ? DateTime.parse(b['updatedAt']) : DateTime(0);
          return bT.compareTo(aT);
        });
      }
      if (mounted) setState(() { _penyakitList = data; _loadingPenyakit = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingPenyakit = false);
    }
  }

  Future<void> _deletePenanganan(Map<String, dynamic> item,
      {String? gejalaId}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus penanganan ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      final res = await _service.deletePenangananPenyakitAyam(item['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['status']
            ? 'Penanganan berhasil dihapus'
            : (res['message'] ?? 'Gagal')),
        backgroundColor: res['status'] ? Colors.green : Colors.red,
      ));
      if (res['status']) {
        if (gejalaId != null) {
          // refresh cache gejala ini
          _penangananCache.remove(gejalaId);
          await _fetchPenangananForGejala(gejalaId);
        } else {
          _fetchPenyakit();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ── BY GEJALA ─────────────────────────────────────────────────────────────

  Future<void> _fetchAllGejala() async {
    try {
      final data = await _service.getGejala();
      if (mounted) setState(() { _allGejala = data; _loadingGejala = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingGejala = false);
    }
  }

  /// Fetch penanganan untuk satu gejala (lazy, dengan cache).
  Future<void> _fetchPenangananForGejala(String gejalaId) async {
    if (_penangananCache.containsKey(gejalaId)) return; // sudah ter-cache
    if (_loadingGejalaIds.contains(gejalaId)) return;   // sedang loading

    setState(() => _loadingGejalaIds.add(gejalaId));
    try {
      final data = await _service.getPenangananByGejala([gejalaId]);
      if (mounted) {
        setState(() {
          _penangananCache[gejalaId] = data;
          _loadingGejalaIds.remove(gejalaId);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _penangananCache[gejalaId] = [];
          _loadingGejalaIds.remove(gejalaId);
        });
      }
    }
  }

  // ── SHARED HELPERS ────────────────────────────────────────────────────────

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

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
            title: 'Kelola Penanganan Penyakit Ayam',
            greeting: 'Kelola Penanganan',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            BannerWidget(
              title: 'Kelola Penanganan',
              subtitle:
                  'Lihat & kelola penanganan berdasarkan penyakit atau gejala',
            ),
            // ── Tab Bar ────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: green1,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: semibold14,
                unselectedLabelStyle: regular14,
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: 'By Penyakit'),
                  Tab(text: 'By Gejala'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // ── Tab Views ──────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildByPenyakitTab(),
                  _buildByGejalaTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 1: BY PENYAKIT ────────────────────────────────────────────────────

  Widget _buildByPenyakitTab() {
    if (_loadingPenyakit) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_penyakitList.isEmpty) {
      return _buildEmpty('Tidak ada data penyakit atau penanganan');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _penyakitList.length,
      itemBuilder: (context, index) {
        final penyakit = _penyakitList[index];
        final hasPenanganan = penyakit.penanganan.isNotEmpty;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(penyakit.namaPenyakit,
                  style: semibold14.copyWith(color: Colors.black87)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: hasPenanganan
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hasPenanganan
                            ? 'Penanganan tersedia'
                            : 'Belum ada penanganan',
                        style: regular12.copyWith(
                            color: hasPenanganan
                                ? Colors.green.shade700
                                : Colors.orange.shade700),
                      ),
                    ),
                  ]),
                  if (hasPenanganan) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Diupdate: ${_formatDate(penyakit.penanganan.first['updatedAt'] as String?)}',
                      style: regular12.copyWith(color: Colors.grey),
                    ),
                  ],
                ],
              ),
              children: [
                if (penyakit.penanganan.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text('Belum ada detail penanganan',
                        style: regular14.copyWith(color: Colors.grey)),
                  )
                else
                  ...penyakit.penanganan.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: _buildPenangananCard(
                        entry.value,
                        entry.key,
                        onEdit: () async {
                          final result = await context.push('/edit-penanganan',
                              extra: TambahPenangananPenyakitAyamScreen(
                                  penanganan: entry.value));
                          if (result == true) _fetchPenyakit();
                        },
                        onDelete: () => _deletePenanganan(entry.value),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── TAB 2: BY GEJALA ──────────────────────────────────────────────────────

  Widget _buildByGejalaTab() {
    if (_loadingGejala) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allGejala.isEmpty) {
      return _buildEmpty('Tidak ada data gejala');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _allGejala.length,
      itemBuilder: (context, index) {
        final gejala = _allGejala[index];
        final cached = _penangananCache[gejala.id];
        final isLoading = _loadingGejalaIds.contains(gejala.id);
        final hasPenanganan = cached != null && cached.isNotEmpty;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onExpansionChanged: (expanded) {
                if (expanded) _fetchPenangananForGejala(gejala.id);
              },
              title: Text(gejala.namaGejala,
                  style: semibold14.copyWith(color: Colors.black87)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(children: [
                    // Status badge — baru muncul setelah di-fetch
                    if (cached != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: hasPenanganan
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hasPenanganan
                              ? 'Penanganan tersedia'
                              : 'Belum ada penanganan',
                          style: regular12.copyWith(
                              color: hasPenanganan
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Tap untuk melihat penanganan',
                            style:
                                regular12.copyWith(color: Colors.grey.shade500)),
                      ),
                  ]),
                  if (hasPenanganan) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${cached!.length} penanganan tersedia',
                      style: regular12.copyWith(color: Colors.grey),
                    ),
                  ],
                ],
              ),
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else if (cached == null || cached.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text('Belum ada detail penanganan',
                        style: regular14.copyWith(color: Colors.grey)),
                  )
                else
                  ...cached.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: _buildPenangananCard(
                        entry.value,
                        entry.key,
                        onEdit: () async {
                          final result = await context.push('/edit-penanganan',
                              extra: TambahPenangananPenyakitAyamScreen(
                                  penanganan: entry.value));
                          if (result == true) {
                            _penangananCache.remove(gejala.id);
                            _fetchPenangananForGejala(gejala.id);
                          }
                        },
                        onDelete: () => _deletePenanganan(entry.value,
                            gejalaId: gejala.id),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── SHARED WIDGETS ────────────────────────────────────────────────────────

  Widget _buildPenangananCard(
    Map<String, dynamic> item,
    int index, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: green1.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['updatedAt'] != null
                      ? _formatDate(item['updatedAt'] as String?)
                      : 'Penanganan ${index + 1}',
                  style: semibold12.copyWith(color: green1),
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(Icons.edit_outlined, size: 18, color: green1),
                ),
              if (onDelete != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['penanganan'] ?? '',
            style: regular14.copyWith(color: dark1),
            textAlign: TextAlign.justify,
          ),
          if (item['gambar'] != null &&
              (item['gambar'] as String).isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['gambar'],
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 120,
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (ctx, err, st) => Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.grey)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              style: regular14.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

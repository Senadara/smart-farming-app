import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/model/Penyakit_Ayam.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_penanganan_penyakit_ayam.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/header.dart';

class PilihPenanganan extends StatefulWidget {
  final String mode; // 'edit' atau 'hapus'

  const PilihPenanganan({super.key, this.mode = 'edit'});

  @override
  State<PilihPenanganan> createState() => _PilihPenangananState();
}

class _PilihPenangananState extends State<PilihPenanganan> {
  final GejalaPenyakitAyam _gejalaService = GejalaPenyakitAyam();
  List<PenyakitAyam> _penyakitList = [];
  bool _isLoading = true;

  bool get _isHapusMode => widget.mode == 'hapus';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _gejalaService.getPenyakitWithPenanganan();
      data.sort((a, b) {
        // Prioritas 1: penyakit yang ada penanganan muncul duluan
        final aHas = a.penanganan.isNotEmpty ? 0 : 1;
        final bHas = b.penanganan.isNotEmpty ? 0 : 1;
        if (aHas != bHas) return aHas.compareTo(bHas);

        // Prioritas 2: urutkan berdasarkan updatedAt terbaru
        final aTime =
            a.penanganan.isNotEmpty && a.penanganan.first['updatedAt'] != null
                ? DateTime.parse(a.penanganan.first['updatedAt'])
                : (a.updatedAt ?? DateTime(0));
        final bTime =
            b.penanganan.isNotEmpty && b.penanganan.first['updatedAt'] != null
                ? DateTime.parse(b.penanganan.first['updatedAt'])
                : (b.updatedAt ?? DateTime(0));
        return bTime.compareTo(aTime);
      });
      for (var penyakit in data) {
        penyakit.penanganan.sort((a, b) {
          final aTime = a['updatedAt'] != null
              ? DateTime.parse(a['updatedAt'])
              : DateTime(0);
          final bTime = b['updatedAt'] != null
              ? DateTime.parse(b['updatedAt'])
              : DateTime(0);
          return bTime.compareTo(aTime);
        });
      }
      debugPrint('Data Penanganan: $data');
      if (mounted) {
        setState(() {
          _penyakitList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _deletePenanganan(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content:
            const Text('Apakah Anda yakin ingin menghapus penanganan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final response =
          await _gejalaService.deletePenangananPenyakitAyam(item['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['status']
              ? 'Penanganan berhasil dihapus'
              : (response['message'] ?? 'Gagal menghapus penanganan')),
          backgroundColor: response['status'] ? Colors.green : Colors.red,
        ));
        if (response['status']) _fetchData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
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
          title: const Header(
              headerType: HeaderType.back,
              title: 'Kelola Penanganan Penyakit Ayam',
              greeting: 'Kelola Penanganan'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BannerWidget(
                title: 'Kelola Penanganan',
                subtitle:
                    'Pilih penanganan penyakit ayam yang ingin diedit atau dihapus',
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_penyakitList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Tidak ada data penanganan')),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors
                              .transparent, // Menghilangkan garis pembatas
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            penyakit.namaPenyakit,
                            style: semibold14.copyWith(color: Colors.black87),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (hasPenanganan)
                                Text(
                                  'Penanganan tersedia',
                                  style:
                                      regular12.copyWith(color: Colors.green),
                                )
                              else
                                Text(
                                  'Belum ada penanganan',
                                  style:
                                      regular12.copyWith(color: Colors.orange),
                                ),
                              if (penyakit.penanganan.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  () {
                                    final t = penyakit.penanganan
                                                .first['updatedAt'] !=
                                            null
                                        ? DateTime.parse(penyakit
                                            .penanganan.first['updatedAt'])
                                        : penyakit.updatedAt;
                                    return t != null
                                        ? 'Diupdate: ${DateFormat('dd MMMM yyyy', 'id_ID').format(t)}'
                                        : '';
                                  }(),
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
                                child: Text(
                                  'Belum ada detail penanganan',
                                  style: regular14.copyWith(color: Colors.grey),
                                ),
                              )
                            else
                              ...penyakit.penanganan
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final i = entry.key;
                                final item = entry.value;
                                return Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: green1.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item['updatedAt'] != null
                                                  ? DateFormat(
                                                          'dd MMMM yyyy',
                                                          'id_ID')
                                                      .format(DateTime.parse(
                                                          item['updatedAt']))
                                                  : 'Penanganan ${i + 1}',
                                              style: semibold12.copyWith(
                                                  color: green1),
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  final result =
                                                      await context.push(
                                                    '/edit-penanganan',
                                                    extra:
                                                        TambahPenangananPenyakitAyamScreen(
                                                            penanganan: item),
                                                  );
                                                  if (result == true) {
                                                    _fetchData();
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.edit_outlined,
                                                  size: 18,
                                                  color: green1,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              GestureDetector(
                                                onTap: () =>
                                                    _deletePenanganan(item),
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['penanganan'] ?? '',
                                        style: regular14.copyWith(color: dark1),
                                        textAlign: TextAlign.justify,
                                      ),
                                      if (item['gambar'] != null &&
                                          (item['gambar'] as String)
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            item['gambar'],
                                            width: double.infinity,
                                            fit: BoxFit.fitWidth,
                                            loadingBuilder:
                                                (ctx, child, progress) {
                                              if (progress == null)
                                                return child;
                                              return const SizedBox(
                                                height: 120,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2)),
                                              );
                                            },
                                            errorBuilder: (ctx, err, st) =>
                                                Container(
                                              height: 200,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Center(
                                                  child: Icon(
                                                      Icons
                                                          .broken_image_outlined,
                                                      color: Colors.grey)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        content: const Text('Apakah Anda yakin ingin menghapus penanganan ini?'),
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
      final response = await _gejalaService.deletePenangananPenyakitAyam(item['id']);
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
              title: 'Pilih Penanganan Penyakit Ayam',
              greeting: 'Menu Utama'),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BannerWidget(
                title: _isHapusMode ? 'Hapus Penanganan' : 'Edit Penanganan',
                subtitle: _isHapusMode
                    ? 'Pilih penanganan yang ingin dihapus'
                    : 'Pilih penanganan penyakit ayam yang akan diedit',
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
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent, // Menghilangkan garis pembatas
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
                                  style: regular12.copyWith(color: green1),
                                )
                              else
                                Text(
                                  'Belum ada penanganan',
                                  style: regular12.copyWith(color: Colors.orange),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                'Dibuat: ${DateFormat('dd MMMM yyyy', 'id_ID').format(penyakit.createdAt!)}',
                                style: regular12.copyWith(color: Colors.grey),
                              ),
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
                              ...penyakit.penanganan.asMap().entries.map((entry) {
                                final i = entry.key;
                                final item = entry.value;
                                return Container(
                                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: green1.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Penanganan ${i + 1}',
                                              style: semibold12.copyWith(color: green1),
                                            ),
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              if (_isHapusMode) {
                                                _deletePenanganan(item);
                                              } else {
                                                context.push(
                                                  '/edit-penanganan',
                                                  extra: TambahPenangananPenyakitAyamScreen(
                                                      penanganan: item),
                                                );
                                              }
                                            },
                                            child: Icon(
                                              _isHapusMode
                                                  ? Icons.delete_outline
                                                  : Icons.edit_outlined,
                                              size: 18,
                                              color: _isHapusMode ? Colors.red : green1,
                                            ),
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
                                              height: 200,
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/model/Penyakit_Ayam.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_penyakit_ayam_screen.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/header.dart';

class PilihPenyakitAyam extends StatefulWidget {
  final String mode; // 'edit' atau 'hapus'

  const PilihPenyakitAyam({super.key, this.mode = 'edit'});

  @override
  State<PilihPenyakitAyam> createState() => _PilihPenyakitAyamState();
}

class _PilihPenyakitAyamState extends State<PilihPenyakitAyam> {
  final GejalaPenyakitAyam _gejalaService = GejalaPenyakitAyam();
  List<PenyakitAyam> _penyakit = [];
  bool _isLoading = true;

  bool get _isHapusMode => widget.mode == 'hapus';

  Future<void> _fetchData() async {
    try {
      final data = await _gejalaService.getPenyakitWithGejala();
      data.sort((a, b) =>
    (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
      setState(() {
        _penyakit = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint(e.toString());
    }
  }

  Future<void> _deletePenyakit(PenyakitAyam penyakit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text.rich(
          TextSpan(
            text: 'Apakah Anda yakin ingin menghapus penyakit:\n\n',
            children: [
              TextSpan(
                text: penyakit.namaPenyakit,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
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
      final response = await _gejalaService.deletePenyakitAyam(penyakit.id);
      if (response['status']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${penyakit.namaPenyakit} berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchData(); // refresh list
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal menghapus penyakit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus penyakit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
              headerType: HeaderType.back,
              title: 'Manajemen Penyakit Ayam',
              greeting: 'Kelola Penyakit Ayam'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BannerWidget(
                title: 'Kelola Penyakit Ayam',
                subtitle: 'Pilih penyakit ayam yang ingin diedit atau dihapus',
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_penyakit.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Tidak ada data penyakit')),
                ),
              if (!_isLoading && _penyakit.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _penyakit.length,
                  itemBuilder: (context, index) {
                    final penyakit = _penyakit[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          penyakit.namaPenyakit,
                          style: semibold14.copyWith(color: Colors.black87),
                        ),
                        subtitle: Text(
                          'Diupdate: ${DateFormat('dd MMMM yyyy', 'id_ID').format(penyakit.updatedAt!)}',
                          style: regular12.copyWith(color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: green1),
                              onPressed: () async {
                                final result = await context.push(
                                  '/edit-penyakit-ayam',
                                  extra: TambahPenyakitAyamScreen(
                                      penyakit: penyakit),
                                );
                                if (result == true) {
                                  _fetchData();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _deletePenyakit(penyakit),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final result = await context.push(
                            '/edit-penyakit-ayam',
                            extra: TambahPenyakitAyamScreen(penyakit: penyakit),
                          );
                          if (result == true) {
                            _fetchData();
                          }
                        },
                      ),
                    );
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/model/gejala_model.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_gejala_screen.dart';
import 'package:smart_farming_app/widget/banner.dart';

class PilihGejalaEditScreen extends StatefulWidget {
  const PilihGejalaEditScreen({super.key});

  @override
  State<PilihGejalaEditScreen> createState() => _PilihGejalaEditScreenState();
}

class _PilihGejalaEditScreenState extends State<PilihGejalaEditScreen> {
  final GejalaPenyakitAyam _gejalaService = GejalaPenyakitAyam();

  List<GejalaModel> _gejala = [];
  
  Future<void> _fetchData() async {
    try {
      final data = await _gejalaService.getGejala();
      setState(() {
        _gejala = data;
      });
    } catch (e) {
      print(e);
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
              title: 'Manajemen Gejala',
              greeting: 'Pilih Gejala Ayam'),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BannerWidget(
                title: 'Pilih Gejala Ayam',
                subtitle: 'Pilih gejala ayam yang ingin diedit',
              ),
              _gejala.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('Tidak ada data gejala')),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _gejala.length,
                      itemBuilder: (context, index) {
                        final gejala = _gejala[index];
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
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.shade100,
                                child: gejala.directGambarUrl.isNotEmpty
                                    ? Image.network(
                                        gejala.directGambarUrl,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                color: Colors.grey),
                                      )
                                    : const Icon(Icons.image,
                                        color: Colors.grey),
                              ),
                            ),
                            title: Text(
                              gejala.namaGejala,
                              style: semibold14.copyWith(color: Colors.black87),
                            ),
                            subtitle: Text(
                              'Dibuat: ${DateFormat('dd MMMM yyyy', 'id_ID').format(gejala.createdAt!)}',
                              style: regular12.copyWith(color: Colors.grey),
                            ),
                            trailing: Icon(Icons.edit_outlined, color: green1),
                            onTap: () {
                              context.push(
                                '/edit-gejala-ayam',
                                extra: TambahGejalaScreen(gejala: gejala),
                              );
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
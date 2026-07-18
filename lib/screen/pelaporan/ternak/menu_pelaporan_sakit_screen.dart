import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_kandang_screen.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/menu_btn.dart';

class MenuPelaporanSakitScreen extends StatefulWidget {
  final String greeting;
  final String tipe;
  final int step;

  const MenuPelaporanSakitScreen({
    super.key,
    required this.greeting,
    required this.tipe,
    required this.step,
  });

  @override
  State<MenuPelaporanSakitScreen> createState() => _MenuPelaporanSakitScreenState();
}

class _MenuPelaporanSakitScreenState extends State<MenuPelaporanSakitScreen> {
  final _step = 1;

  void _navigateTo(String title) {
    switch (title) {
      case 'Buat Laporan Ayam Sakit':
        context.push('/pilih-kandang',
            extra: PilihKandangScreen(
              step: _step,
              tipe: 'sakit',
              greeting: 'Pelaporan Ternak Sakit',
            ));
        break;
      case 'Lihat Laporan Ayam Sakit':
        context.push('/pilih-kandang',
            extra: PilihKandangScreen(
              step: _step,
              tipe: 'lihat-sakit',
              greeting: 'Riwayat Laporan Ayam Sakit',
            ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> reports = [
      {
        'title': 'Buat Laporan Ayam Sakit',
        'icon': 'assets/icons/set/sick-chicken-filled.png',
        'description':
            'Diagnosa dan buat laporan penyakit ayam hasil konsultasi dengan pakar',
      },
      {
        'title': 'Lihat Laporan Ayam Sakit',
        'icon': 'assets/icons/set/sick-chicken-filled.png',
        'description':
            'Liat laporan penyakit ayam',
      },
    ];

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
              title: 'Pelaporan Ternak Sakit',
              greeting: 'Menu Utama'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BannerWidget(
                  title: 'Pelaporan Ternak Sakit',
                  subtitle: 'Pilih menu di bawah untuk membuat laporan penyakit ayam',
                ),
                const SizedBox(height: 12),
                for (var report in reports)
                  MenuButton(
                    key: Key(report['title']),
                    title: report['title'],
                    subtext: report['description'],
                    icon: report['icon'],
                    backgroundColor: Colors.grey.shade200,
                    iconColor: green1,
                    onTap: () => _navigateTo(report['title']),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
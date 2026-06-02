import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/manajemen_gejala.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_gejala_screen.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_penanganan_penyakit_ayam.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_penyakit_ayam_screen.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/menu_btn.dart';

class ManajemenPenyakitAyam extends StatefulWidget {
  const ManajemenPenyakitAyam({super.key});

  @override
  State<ManajemenPenyakitAyam> createState() => _ManajemenPenyakitAyamState();
}

class _ManajemenPenyakitAyamState extends State<ManajemenPenyakitAyam> {
  String? selectedReport;

  void navigateBasedOnSelection() {
    switch (selectedReport){
      case 'Manajemen Gejala':
        context.push('/manajemen-gejala',
            extra: const ManajemenGejala());
        break;
      case 'Manajemen Penyakit':
        context.push('/tambah-penyakit-ayam',
            extra: const TambahPenyakitAyamScreen());
        break;
      case 'Manajemen Penanganan':
        context.push('/tambah-penanganan-penyakit-ayam',
            extra: const TambahPenangananPenyakitAyamScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> reports = [
      {
        'title': 'Manajemen Gejala',
        'icon': 'assets/icons/set/panen-filled.png',
        'description':
            'Catat hasil panen ternak untuk evaluasi dan perencanaan produksi yang lebih baik.',
      },
      {
        'title': 'Manajemen Penyakit',
        'icon': 'assets/icons/set/sick-chicken-filled.png',
        'description':
            'Catat gejala dan kondisi ternak yang mengalami gangguan kesehatan.',
      },
      {
        'title': 'Manajemen Penanganan',
        'icon': 'assets/icons/set/dead-chicken-filled.png',
        'description':
            'Dokumentasikan ternak yang tidak bertahan sebagai bagian dari evaluasi perawatan.',
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
              title: 'Manajemen Penyakit Ayam',
              greeting: 'Menu Utama'),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BannerWidget(
                  title: 'Manajemen Penyakit Ayam',
                  subtitle: 'Pilih menu di bawah untuk mengelola penyakit ayam',
                ),
                const SizedBox(height: 12),
                for(var report in reports)
                MenuButton(
                    key: Key(report['title']),
                    title: report['title'],
                    subtext: report['description'],
                    icon: report['icon'],
                    backgroundColor: Colors.grey.shade200,
                    iconColor: green1,
                    isSelected: selectedReport == report['title'],
                    onTap: () {
                      setState(() {
                        selectedReport = report['title'];
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
              onPressed: () {
                navigateBasedOnSelection();
              },
              buttonText: 'Selanjutnya',
              backgroundColor: green1,
              textStyle: semibold16.copyWith(color: white),
              key: const Key('next_button')),
        ),
      ),
    );
  }
}
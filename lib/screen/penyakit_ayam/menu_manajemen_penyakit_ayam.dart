import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/manajemen_gejala.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/manajemen_penanganan.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/manajemen_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/menu_btn.dart';

class MenuManajemenPenyakitAyam extends StatefulWidget {
  const MenuManajemenPenyakitAyam({super.key});

  @override
  State<MenuManajemenPenyakitAyam> createState() => _MenuManajemenPenyakitAyamState();
}

class _MenuManajemenPenyakitAyamState extends State<MenuManajemenPenyakitAyam> {
  String? selectedReport;

  void navigateBasedOnSelection() {
    switch (selectedReport){
      case 'Manajemen Gejala':
        context.push('/manajemen-gejala',
            extra: const ManajemenGejala());
        break;
      case 'Manajemen Penyakit':
        context.push('/manajemen-penyakit-ayam',
            extra: const ManajemenPenyakitAyam());
        break;
      case 'Manajemen Penanganan':
        context.push('/manajemen-penanganan-ayam',
            extra: const ManajemenPenanganan());
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
            padding: const EdgeInsets.only(bottom: 16),
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
                      navigateBasedOnSelection();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
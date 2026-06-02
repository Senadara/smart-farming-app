import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/delete_gejala_screen.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_gejala_screen.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/menu_btn.dart';

class ManajemenGejala extends StatefulWidget {
  const ManajemenGejala({super.key});

  @override
  State<ManajemenGejala> createState() => _ManajemenGejalaState();
}

class _ManajemenGejalaState extends State<ManajemenGejala> {
  String? selectedReport;

  void navigateBasedOnSelection() {
    switch (selectedReport){
      case 'Tambah Gejala':
        context.push('/tambah-gejala-ayam',
            extra: const TambahGejalaScreen());
        break;
      case 'Hapus Gejala':
        context.push('/delete-gejala-ayam',
            extra: const DeleteGejalaScreen());
        break;
      // case 'Manajemen Penanganan':
      //   context.push('/tambah-penanganan-penyakit-ayam',
      //       extra: const TambahPenangananPenyakitAyamScreen());
      //   break;
    }
  }
  
  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> reports = [
      {
        'title': 'Tambah Gejala',
        'icon': 'assets/icons/set/panen-filled.png',
        'description':
            'Tambah gejala penyakit ayam hasil konsultasi dengan pakar',
      },
      {
        'title': 'Hapus Gejala',
        'icon': 'assets/icons/set/sick-chicken-filled.png',
        'description':
            'Hapus gejala penyakit ayam hasil konsultasi dengan pakar',
      },
      {
        'title': 'Edit Gejala',
        'icon': 'assets/icons/set/dead-chicken-filled.png',
        'description':
            'Edit gejala penyakit ayam hasil konsultasi dengan pakar',
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
                  title: 'Manajemen Gejala Ayam',
                  subtitle: 'Pilih menu di bawah untuk mengelola gejala penyakit ayam',
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/pilih_penyakit_ayam.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_penyakit_ayam_screen.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
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
      case 'Tambah Penyakit Ayam':
        context.push('/tambah-penyakit-ayam',
            extra: const TambahPenyakitAyamScreen());
        break;
      case 'Kelola Penyakit Ayam':
        context.push('/pilih-penyakit-edit',
            extra: const PilihPenyakitAyam());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> menu = [
      {
        'title': 'Tambah Penyakit Ayam',
        'icon': 'assets/icons/set/sick-chicken-filled.png',
        'description':
            'Tambah penyakit ayam sesuai arahan pakar',
      },
      {
        'title': 'Kelola Penyakit Ayam',
        'icon': 'assets/icons/set/sick-chicken-filled.png',
        'description':
            'Edit atau hapus penyakit ayam sesuai arahan pakar',
      },
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 100,
          title: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Header(
              headerType: HeaderType.back,
              title: 'Manajemen Penyakit Ayam',
              greeting: 'Menu Utama',
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                BannerWidget(
                  title: 'Manajemen Penyakit Ayam',
                  subtitle: 'Pilih menu di bawah untuk mengelola penyakit ayam',
                ),
                const SizedBox(height: 12),
                for(var report in menu)
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
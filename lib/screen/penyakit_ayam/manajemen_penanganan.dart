import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/pilih_penanganan.dart';
import 'package:smart_farming_app/screen/penyakit_ayam/tambah_penanganan_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/menu_btn.dart';

class ManajemenPenanganan extends StatefulWidget {
  const ManajemenPenanganan({super.key});

  @override
  State<ManajemenPenanganan> createState() => _ManajemenPenangananState();
}

class _ManajemenPenangananState extends State<ManajemenPenanganan> {
  String? selectedMenu;

  void navigateBasedOnSelection() {
    switch (selectedMenu){
      case 'Tambah Penanganan':
        context.push('/tambah-penanganan-penyakit-ayam',
            extra: const TambahPenangananPenyakitAyamScreen());
        break;
      case 'Edit Penanganan':
        context.push('/pilih-penanganan',
            extra: const PilihPenanganan(mode: 'edit'));
        break;
      case 'Hapus Penanganan':
        context.push('/pilih-penanganan-hapus',
            extra: const PilihPenanganan(mode: 'hapus'));
        break;
    }
  }

  List<Map<String, dynamic>> menu = [
    {
      'title': 'Tambah Penanganan',
      'icon': 'assets/icons/set/panen-filled.png',
      'description':
          'Tambah penanganan penyakit ayam hasil konsultasi dengan pakar',
    },
    {
      'title': 'Edit Penanganan',
      'icon': 'assets/icons/set/panen-filled.png',
      'description':
          'Edit penanganan penyakit ayam hasil konsultasi dengan pakar',
    },
    {
      'title': 'Hapus Penanganan',
      'icon': 'assets/icons/set/panen-filled.png',
      'description':
          'Hapus penanganan penyakit ayam hasil konsultasi dengan pakar',
    },
  ];

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
              title: 'Manajemen Penanganan Penyakit',
              greeting: 'Menu Utama'),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              BannerWidget(
                title: 'Manajemen Penanganan Ayam',
                subtitle: 'Pilih menu di bawah untuk mengelola penanganan penyakit ayam',
              ),
              const SizedBox(height: 12),
              for(var menu in menu)
                MenuButton(
                    key: Key(menu['title']),
                    title: menu['title'],
                    subtext: menu['description'],
                    icon: menu['icon'],
                    backgroundColor: Colors.grey.shade200,
                    iconColor: green1,
                    isSelected: selectedMenu == menu['title'],
                    onTap: () {
                      setState(() {
                        selectedMenu = menu['title'];
                      });
                    },
                  ),
            ],
          ),
        )
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
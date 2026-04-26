import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';

class PilihGejalaScreen extends StatefulWidget {
  final String greeting;
  final String tipe;
  final int step;
  final Map<String, dynamic> data;

  const PilihGejalaScreen({
    super.key,
    required this.greeting,
    required this.tipe,
    required this.step,
    required this.data,
  });

  @override
  State<PilihGejalaScreen> createState() => _PilihGejalaScreenState();
}

class _PilihGejalaScreenState extends State<PilihGejalaScreen> {
  // Daftar gejala yang tersedia
  final List<Map<String, String>> _daftarGejala = [
    {
      'label': 'Nafsu makan menurun',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Nafsu_makan_menurun-removebg-preview.png',
    },
    {
      'label': 'Ngorok',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Ngorok-removebg-preview.png',
    },
    {
      'label': 'Produksi telur menurun',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Produksi_telur_menurun-removebg-preview.png',
    },
    {
      'label': 'Jengger membiru',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Jengger_membiru-removebg-preview.png',
    },
    {
      'label': 'Batuk',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Batuk-removebg-preview.png',
    },
    {
      'label': 'Leleran hidung',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Leleran_hidung-removebg-preview.png',
    },
    {
      'label': 'Depresi',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Depresi-removebg-preview.png',
    },
    {
      'label': 'Tampak sayu',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Tampak_sayu-removebg-preview.png',
    },
    {
      'label': 'Tremor',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Tremor-removebg-preview.png',
    },
    {
      'label': 'Jengger pucat',
      'image':
          'assets/images/ilustrasiGejala/Ilustrasi_Jengger_pucat-removebg-preview.png',
    },
  ];

  // Set index gejala yang dipilih
  final Set<int> _selectedGejala = {};

  void _toggleGejala(int index) {
    setState(() {
      if (_selectedGejala.contains(index)) {
        _selectedGejala.remove(index);
      } else {
        _selectedGejala.add(index);
      }
    });
  }

  void _submitForm() {
    if (_selectedGejala.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih setidaknya satu gejala.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedLabels =
        _selectedGejala.map((i) => _daftarGejala[i]['label']!).toSet();

    // Hitung Certainty Factor untuk setiap penyakit
    final hasilCF = hitungCF(selectedLabels);

    if (hasilCF.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Tidak ada penyakit yang cocok dengan gejala yang dipilih.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final diagnosisTeratas = hasilCF.first;

    final updatedData = Map<String, dynamic>.from(widget.data);
    updatedData['gejala'] = selectedLabels.toList();
    updatedData['namaPenyakit'] = diagnosisTeratas.namaPenyakit;
    updatedData['cfScore'] = diagnosisTeratas.cfScore;
    updatedData['hasilCF'] = hasilCF
        .map((h) => {'namaPenyakit': h.namaPenyakit, 'cfScore': h.cfScore})
        .toList();

    debugPrint('[CF] Hasil diagnosis: $hasilCF');

    context.push('/hasil-diagnosis-penyakit',
        extra: HasilDiagnosisPenyakitScreen(
          greeting: widget.greeting,
          data: updatedData,
          tipe: widget.tipe,
          step: widget.step + 1,
        ));
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
          title: Header(
            headerType: HeaderType.back,
            title: 'Menu Pelaporan',
            greeting: widget.greeting,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BannerWidget(
              title: 'Step ${widget.step} - Pilih Gejala',
              subtitle: 'Pilih gejala yang dialami oleh ternak!',
              showDate: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _daftarGejala.length,
                  itemBuilder: (context, index) {
                    return GejalaItemCard(
                      gejala: _daftarGejala[index],
                      isSelected: _selectedGejala.contains(index),
                      onTap: () => _toggleGejala(index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Button Next
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                onPressed: _submitForm,
                buttonText: 'Selanjutnya',
                backgroundColor: green1,
                textStyle: semibold16.copyWith(color: white),
                key: const Key('next_button_pilih_gejala'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

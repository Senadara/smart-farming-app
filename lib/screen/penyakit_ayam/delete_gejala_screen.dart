import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/gejala_model.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/gejala_item_card.dart';
import 'package:smart_farming_app/widget/header.dart';

class DeleteGejalaScreen extends StatefulWidget {
  const DeleteGejalaScreen({super.key});

  @override
  State<DeleteGejalaScreen> createState() => _DeleteGejalaScreenState();
}

class _DeleteGejalaScreenState extends State<DeleteGejalaScreen> {
  final GejalaPenyakitAyam _gejalaService = GejalaPenyakitAyam();
  List<GejalaModel> _daftarGejala = [];
  final Set<int> _selectedGejala = {};
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> _fetchGejala() async {
    try {
      final gejalaList = await _gejalaService.getGejala();
      setState(() {
        _daftarGejala = gejalaList;
        _isLoading = false;
      });
      debugPrint('[delete_gejala_screen]: ${_daftarGejala.toString()}');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint('Error fetching gejala: $e');
    }
  }
  
  void _toggleGejala(int index) {
    setState(() {
      if (_selectedGejala.contains(index)) {
        _selectedGejala.remove(index);
      } else {
        _selectedGejala.add(index);
      }
    });
  }

  void _submitForm() async {
    if (_selectedGejala.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih minimal satu gejala'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedNames = _selectedGejala
        .map((i) => _daftarGejala[i].namaGejala)
        .join(', ');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text.rich(
          TextSpan(
            text: 'Apakah Anda yakin ingin menghapus ${_selectedGejala.length} gejala berikut?\n\n',
            children: [
              TextSpan(
                text: selectedNames,
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

    if (confirm != true) return;

    // TODO: lakukan proses delete di sini
  }

  @override
  void initState() {
    super.initState();
    _fetchGejala();
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
                title: 'Hapus Gejala',
                greeting: 'Manajemen Gejala Ayam'),
            ),
        ),

                body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BannerWidget(
                        title: 'Hapus Gejala',
                        subtitle: 'Pilih gejala penyakit ayam yang ingin dihapus',
                    ),
                    Expanded(
                      child: _buildBody(),
                    )
                  ],
                ),
            )
          ),

        bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                onPressed:
                    _isLoading || _errorMessage != null || _daftarGejala.isEmpty
                        ? null
                        : _submitForm,
                buttonText: 'Hapus Gejala',
                backgroundColor:
                    _isLoading || _errorMessage != null || _daftarGejala.isEmpty
                        ? Colors.grey
                        : green1,
                textStyle: semibold16.copyWith(color: white),
                key: const Key('next_button_pilih_gejala'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: green1),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: regular14.copyWith(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchGejala,
              style: ElevatedButton.styleFrom(backgroundColor: green1),
              child:
                  Text('Coba Lagi', style: semibold14.copyWith(color: white)),
            ),
          ],
        ),
      );
    }

    if (_daftarGejala.isEmpty) {
      return const Center(
        child: Text('Tidak ada data gejala tersedia.'),
      );
    }

    debugPrint(_daftarGejala.toString());

    return Padding(
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
    );
  }
}
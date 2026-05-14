import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/model/gejala_model.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/hasil_diagnosa_penyakit.dart';
import 'package:smart_farming_app/service/gejala_penyakit_ayam.dart';
import 'package:smart_farming_app/theme.dart';

import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/gejala_item_card.dart';
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
  final GejalaPenyakitAyam _gejalaService = GejalaPenyakitAyam();
  List<GejalaModel> _daftarGejala = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Set index gejala yang dipilih
  final Set<int> _selectedGejala = {};

  @override
  void initState() {
    super.initState();
    _fetchGejala();
  }

  Future<void> _fetchGejala() async {
    debugPrint("[PilihGejalaScreen] Triggering _fetchGejala...");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gejalaList = await _gejalaService.getGejala();
      setState(() {
        _daftarGejala = gejalaList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat gejala: $e';
        _isLoading = false;
      });
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
        const SnackBar(
          content: Text('Harap pilih setidaknya satu gejala.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<String> selectedIds =
          _selectedGejala.map((i) => _daftarGejala[i].id).toList();

      debugPrint('[CF] Mengirim ID Gejala: $selectedIds');

      final response = await _gejalaService.diagnoseAyam(selectedIds);
      debugPrint('[CF] Response diagnosa: $response');

      if (response['status']) {
        final result = response['data'];
        final updatedData = Map<String, dynamic>.from(widget.data);

        updatedData['namaPenyakit'] = result['penyakit'];
        updatedData['penyakitId'] =
            result['id']; // Assuming 'id' is the disease ID
        updatedData['cfScore'] = (result['cf_score'] as num).toDouble();
        final rawPenanganan = result['penanganan'] as List<dynamic>? ?? [];
        updatedData['penanganan'] = rawPenanganan.map((p) => {
          'nama': p['nama'] ?? 'Penanganan',
          'deskripsi': p['penanganan'] ?? p['deskripsi'] ?? '',
        }).toList();

        updatedData['gejala'] = result['gejala_terdeteksi'] ??
            _selectedGejala
                .map((i) => _daftarGejala[i].namaGejala)
                .toList();
        updatedData['selectedGejalaIds'] = selectedIds;

        debugPrint('[CF] Hasil diagnosis dari API: $result');

        if (mounted) {
          context.push('/hasil-diagnosis-penyakit',
              extra: HasilDiagnosisPenyakitScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1,
              ));
        }
      } else {
        throw Exception(response['message'] ?? 'Gagal melakukan diagnosa');
      }
    } catch (e) {
      debugPrint('[CF] Error diagnosa: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan diagnosa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              child: _buildBody(),
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
                onPressed:
                    _isLoading || _errorMessage != null || _daftarGejala.isEmpty
                        ? null
                        : _submitForm,
                buttonText: 'Selanjutnya',
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

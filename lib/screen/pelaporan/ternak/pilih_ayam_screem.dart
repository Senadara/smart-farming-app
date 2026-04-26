import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/model/ayam.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_gejala_screen.dart';
import 'package:smart_farming_app/service/objek_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/info_ayam.dart';
import 'package:smart_farming_app/widget/kandang_layout_widget.dart';

class PilihAyamScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PilihAyamScreen({
    super.key,
    this.data,
    required this.greeting,
    required this.tipe,
    required this.step,
  });

  @override
  State<PilihAyamScreen> createState() => _PilihAyamScreenState();
}

class _PilihAyamScreenState extends State<PilihAyamScreen> {
  final ObjekBudidayaService _objekBudidayaService = ObjekBudidayaService();

  List<dynamic> _listTernak = [];
  final List<Map<String, dynamic>> _selectedTernak = [];
  List<String> _selectedAyamIds =
      []; // ID ayam yang dipilih dari layout kandang

  // Layout kandang dibuat setelah fetch API selesai
  List<List<Ayam>> _ayamLayout = [];

  Future<void> _fetchData() async {
    try {
      Map<String, dynamic> response = {};

      final unitBudidaya = widget.data?['unitBudidaya'];
      final int kapasitas = unitBudidaya?['kapasitas'] ?? 0;

      response = await _objekBudidayaService
          .getObjekBudidayaByUnitBudidaya(unitBudidaya['id']);

      debugPrint("[Debug] Response: ${response.toString()}");
      if (response['status']) {
        setState(() {
          _listTernak = response['data'] ?? [];
          _ayamLayout = generateAyamLayoutFromApi(
            dataApi: _listTernak,
            kapasitas: kapasitas,
          );
        });
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _submitForm() async {
    if (_selectedAyamIds.isEmpty) {
      showAppToast(
        context,
        'Harap pilih setidaknya satu ternak untuk melanjutkan.',
        isError: true,
      );
      return;
    }

    final updatedData = Map<String, dynamic>.from(widget.data ?? {});
    updatedData['selectedAyamIds'] = _selectedAyamIds;

    context.push('/pilih-gejala',
        extra: PilihGejalaScreen(
          greeting: widget.greeting,
          data: updatedData,
          tipe: widget.tipe,
          step: widget.step + 1,
        ));
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
      // Header
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
              title: 'Step ${widget.step} - Pilih Ternak',
              subtitle: 'Pilih ternak yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                child: KandangLayoutWidget(
                  ayamLayout: _ayamLayout,
                  onSelectionChanged: (ids) {
                    setState(() {
                      _selectedAyamIds = ids;
                    });
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
            const InfoAyam(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                  onPressed: () {
                    _submitForm();
                  },
                  buttonText: 'Selanjutnya',
                  backgroundColor: green1,
                  textStyle: semibold16.copyWith(color: white),
                  key: const Key('next_button_pilih_ternak')),
            ),
          ],
        ),
      ),
    );
  }
}

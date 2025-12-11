import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/widget/card_device_iot.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/chart_widget.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class DetailCpSawi extends StatefulWidget {
  final String? idKolam;

  const DetailCpSawi({super.key, this.idKolam});

  @override
  State<DetailCpSawi> createState() => _DetailCpSawiState();
}

class _DetailCpSawiState extends State<DetailCpSawi> {
  final DashboardService _dashboardService = DashboardService();
  final HamaService _hamaService = HamaService();

  Map<String, dynamic>? _perkebunanData;
  Map<String, dynamic>? _peternakanData;
  List<dynamic> _laporanHamaList = [];
  bool _isLoading = true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPerkebunanKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPeternakanKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchData(isRefresh: false);
  }

  Future<void> _fetchData({isRefresh = false}) async {
    if (!isRefresh && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        _dashboardService.getDashboardPerkebunan(),
        _dashboardService.getDashboardPeternakan(),
        _hamaService.getLaporanHama(),
      ]);

      if (!mounted) return;
      setState(() {
        _perkebunanData = results[0];
        // _peternakanData = results[1];
        _laporanHamaList = results[2]['data'] ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// INI HARUS DISESUAIKAN DENGAN BANYAK JENIS HEWAN YANG ADA
  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Lele',
    'Ayam',
  ];
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPerkebunanContent() {
    if (!_isLoading && _perkebunanData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Gagal memuat data perkebunan.",
                style: regular12.copyWith(color: dark2),
                key: const Key('no_data_found')),
            const SizedBox(height: 10),
            ElevatedButton(
              key: const Key('retry_button'),
              onPressed: () {
                _fetchData(isRefresh: true);
              },
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    //================================
    //===   CARD INDIKATOR LELE    ===
    //================================
    return RefreshIndicator(
      key: _refreshIndicatorPerkebunanKey,
      onRefresh: () => _fetchData(isRefresh: true),
      color: green1,
      backgroundColor: white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (_perkebunanData != null) ...[
            DashboardGrid(
              title: 'Statistik Rata-rata Kolam Hari Ini',
              items: [
                DashboardItem(
                  title: 'Jumlah Populasi',
                  value: _perkebunanData?['jumlahSakit'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Suhu Air (°C)',
                  value: _perkebunanData?['suhu'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'PH Air',
                  value: _perkebunanData?['jenisTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: blue3,
                  iconColor: blue1,
                ),
                DashboardItem(
                  title: 'DO Air (mg/L)',
                  value: _perkebunanData?['jumlahKematian'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Kekeruhan Air (NTU)',
                  value: _perkebunanData?['jumlahPanen'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Tinggi Air (cm)',
                  value: _perkebunanData?['jumlahTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green4,
                  iconColor: green2,
                ),
              ],
              crossAxisCount: 3,
              valueFontSize: 32,
              titleFontSize: 13.5,
              paddingSize: 10,
              iconsWidth: 36,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                CardDeviceIot(
                  title: "Pemberian Pakan",
                  status: "Mati",
                  schedule: "07:00 | 15:00",
                  isActive: false,
                  assetIcon: 'assets/icons/set/wateringCan-filled.png',
                  onTapPower: () {},
                ),
                CardDeviceIot(
                  title: "Aerator",
                  status: "Hidup",
                  isActive: true,
                  assetIcon: 'assets/icons/set/wateringCan-filled.png',
                  onTapPower: () {},
                ),
              ],
            ),
            // Column(
            //   children:
            //       (_perkebunanData?['daftarPerangkat'] as List<dynamic>? ?? [])
            //           .map((device) {
            //     final title = device['nama'] ?? '-';
            //     final status =
            //         (device['status'] ?? '').toString().toLowerCase();
            //     final isActive = status == "hidup";
            //     final schedule = device['jadwal'];
            //     final icon = device['gambar'] ??
            //         'assets/icons/set/wateringCan-filled.png';

            //     return CardDeviceIot(
            //       title: title,
            //       status: isActive ? "Hidup" : "Mati",
            //       schedule: schedule, // null? otomatis tidak ditampilkan
            //       isActive: isActive,
            //       assetIcon: icon,
            //       onTapPower: () {
            //         final id = device['id'];
            //         print("Toggle perangkat ID: $id");
            //         // panggil API toggle di sini
            //       },
            //     );
            //   }).toList(),
            // )
            const SizedBox(height: 24),
          ] else if (!_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Gagal memuat data perkebunan."),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _fetchData(isRefresh: true),
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
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
          title: const Header(
              headerType: HeaderType.menu,
              title: 'Menu Aplikasi',
              greeting: 'Panel Kontrol Peternakan'),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: _isLoading &&
                      (_perkebunanData == null || _peternakanData == null)
                  ? const Center(child: CircularProgressIndicator())
                  : NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                              Container(
                                color: Colors.white,
                                child: Tabs(
                                  onTabChanged: _onTabChanged,
                                  selectedIndex: _selectedTabIndex,
                                  tabTitles: tabList,
                                ),
                              ),
                              60.0,
                            ),
                            pinned: true,
                          ),
                        ];
                      },
                      body: Column(
                        children: [
                          const SizedBox(height: 12),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _selectedTabIndex = index;
                                });
                              },
                              children: [
                                _buildPerkebunanContent(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._child, this._height);

  final Widget _child;
  final double _height;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: _child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate._child != _child || oldDelegate._height != _height;
  }
}

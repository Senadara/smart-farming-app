import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/chart_widget.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/service/sensor_cp.dart';

class DashboardCpPerkebunan extends StatefulWidget {
  const DashboardCpPerkebunan({super.key});

  @override
  State<DashboardCpPerkebunan> createState() => _DashboardCpPerkebunanState();
}

class _DashboardCpPerkebunanState extends State<DashboardCpPerkebunan> {
  // ===============================
  // 📦 SERVICES
  // ===============================
  final DashboardService _dashboardService = DashboardService();
  final HamaService _hamaService = HamaService();
  final SensorService _sensorService = SensorService();

  // ===============================
  // 📊 STATE DATA
  // ===============================
  Map<String, dynamic>? _perkebunanData;
  Map<String, dynamic>? _peternakanData;
  // List<dynamic> _laporanHamaList;

  bool _isLoading = true;

  // ===============================
  // 🔄 REFRESH INDICATORS
  // ===============================
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPerkebunanKey =
      GlobalKey<RefreshIndicatorState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPeternakanKey =
      GlobalKey<RefreshIndicatorState>();

  // ===============================
  // 🚀 INIT
  // ===============================
  @override
  void initState() {
    super.initState();
    _fetchData(isRefresh: false);
  }

  // ===============================
  // 📡 FETCH DATA
  // ===============================
  Future<void> _fetchData({bool isRefresh = false}) async {
    if (!isRefresh && !_isLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final results = await Future.wait([
        _dashboardService.getDashboardPerkebunan(),
        _dashboardService.getDashboardPeternakan(),
        _hamaService.getLaporanHama(),
        // 📡 SENSOR (AUTO TOKEN)
        _sensorService.getLatestSensor(),
      ]);

      if (!mounted) return;

      final perkebunan = results[0] as Map<String, dynamic>;
      final sensorData = results[3] as Map<String, dynamic>;

      // ===============================
      // 🔗 MERGE SENSOR → PERKEBUNAN
      // ===============================
      setState(() {
        _perkebunanData = {
          ...perkebunan,
          'suhu': sensorData['temperature'],
          'humidity': sensorData['humidity'],
          'nitrogen': sensorData['nitrogen'],
          'phosphor': sensorData['phosphor'],
          'potassium': sensorData['potassium'],
          'ec': sensorData['ec'],
          'ph': sensorData['ph'],
          'createdAt': sensorData['createdAt'],
        };
      });
    } catch (e) {
      if (!mounted) return;
      showAppToast(
        context,
        'Terjadi kesalahan: $e. Silakan coba lagi',
        title: 'Error Tidak Terduga 😢',
      );
    } finally {
      if (!mounted) return;
      if (_isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

// INI HARUS DISESUAIKAN DENGAN BANYAK JENIS HEWAN YANG ADA
  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Melon',
    'Sawi',
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

  Widget _buildSawiContent() {
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
    //===   CARD INDIKATOR SAWI    ===
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
              title: 'Statistik Rata-rata Kebun Hari Ini',
              items: [
                DashboardItem(
                  title: 'humidity (%)',
                  value: _perkebunanData?['humidity'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _perkebunanData?['suhu'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Nitrogen (mg/kg)',
                  value: _perkebunanData?['nitrogen'].toString() ?? '-',
                  icon: 'other',
                  bgColor: blue3,
                  iconColor: blue1,
                ),
                DashboardItem(
                  title: 'Phosphor (mg/kg)',
                  value: _perkebunanData?['phosphor'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Potasium (mg/kg)',
                  value: _perkebunanData?['potassium'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Jumlah Tanaman',
                  value: _perkebunanData?['jumlahTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green4,
                  iconColor: green2,
                ),
              ],
              crossAxisCount: 2,
              valueFontSize: 60,
              // titleFontSize: 13.5,
              // paddingSize: 10,
              // iconsWidth: 36,
            ),
            const SizedBox(height: 12),

            // ListItem(
            //   title: 'Control Panel Per Jenis Tanaman',
            //   items: (_perkebunanData?['daftarKebun'] as List<dynamic>? ?? [])
            //       .map((tanaman) => {
            //             'id': tanaman['id'],
            //             'name': tanaman['nama'],
            //             'isActive': tanaman['status'],
            //             'icon': tanaman['gambar'],
            //           })
            //       .toList(),
            //   type: 'basic',
            //   onItemTap: (context, item) {
            //     final id = item['id'] ?? '';
            //     context.push('/detail-cp-kolam/$id').then((_) {
            //       _fetchData(isRefresh: true);
            //     });
            //   },
            // ),
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

  Widget _buildMelonContent() {
    if (!_isLoading && _perkebunanData == null) {
      return Center(
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
      );
    }

    //================================
    //===   CARD INDIKATOR MELON    ===
    //================================
    return RefreshIndicator(
      key: _refreshIndicatorPeternakanKey,
      onRefresh: () => _fetchData(isRefresh: true),
      color: green1,
      backgroundColor: white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (_perkebunanData != null) ...[
            DashboardGrid(
              title: 'Statistik Rata-rata Kebun Hari Ini',
              items: [
                DashboardItem(
                  title: 'Tanaman Sakit',
                  value: _perkebunanData?['jumlahSakit'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _perkebunanData?['suhu'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Jenis Tanaman',
                  value: _perkebunanData?['jenisTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: blue3,
                  iconColor: blue1,
                ),
                DashboardItem(
                  title: 'Tanaman Mati',
                  value: _perkebunanData?['jumlahKematian'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Jumlah Panen',
                  value: _perkebunanData?['jumlahPanen'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Jumlah Tanaman',
                  value: _perkebunanData?['jumlahTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green4,
                  iconColor: green2,
                ),
              ],
              crossAxisCount: 2,
              valueFontSize: 60,
              // titleFontSize: 13.5,
              // paddingSize: 10,
              // iconsWidth: 36,
            ),
            const SizedBox(height: 12),

            // ListItem(
            //   title: 'Hasil Laporan Per Jenis Ternak',
            //   items: (_perkebunanData?['daftarKebun'] as List<dynamic>? ?? [])
            //       .map((ternak) => {
            //             'id': ternak['id'],
            //             'name': ternak['nama'],
            //             'isActive': ternak['status'],
            //             'icon': ternak['gambar'],
            //           })
            //       .toList(),
            //   type: 'basic',
            //   onItemTap: (context, item) {
            //     final id = item['id'] ?? '';
            //     context.push('/detail-cp-kandang/$id').then((_) {
            //       _fetchData(isRefresh: true);
            //     });
            //   },
            // ),

            const SizedBox(height: 12),
          ] else if (!_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Gagal memuat data peternakan."),
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

  Widget _buildAnggurContent() {
    if (!_isLoading && _perkebunanData == null) {
      return Center(
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
      );
    }

    //================================
    //===   CARD INDIKATOR ANGGUR   ===
    //================================
    return RefreshIndicator(
      key: _refreshIndicatorPeternakanKey,
      onRefresh: () => _fetchData(isRefresh: true),
      color: green1,
      backgroundColor: white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (_perkebunanData != null) ...[
            DashboardGrid(
              title: 'Statistik Rata-rata Kebun Hari Ini',
              items: [
                DashboardItem(
                  title: 'Tanaman Sakit',
                  value: _perkebunanData?['jumlahSakit'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _perkebunanData?['suhu'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Jenis Tanaman',
                  value: _perkebunanData?['jenisTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: blue3,
                  iconColor: blue1,
                ),
                DashboardItem(
                  title: 'Tanaman Mati',
                  value: _perkebunanData?['jumlahKematian'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Jumlah Panen',
                  value: _perkebunanData?['jumlahPanen'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Jumlah Tanaman',
                  value: _perkebunanData?['jumlahTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green4,
                  iconColor: green2,
                ),
              ],
              crossAxisCount: 2,
              valueFontSize: 60,
              // titleFontSize: 13.5,
              // paddingSize: 10,
              // iconsWidth: 36,
            ),
            const SizedBox(height: 12),

            // ListItem(
            //   title: 'Hasil Laporan Per Jenis Ternak',
            //   items: (_perkebunanData?['daftarKebun'] as List<dynamic>? ?? [])
            //       .map((ternak) => {
            //             'id': ternak['id'],
            //             'name': ternak['nama'],
            //             'isActive': ternak['status'],
            //             'icon': ternak['gambar'],
            //           })
            //       .toList(),
            //   type: 'basic',
            //   onItemTap: (context, item) {
            //     final id = item['id'] ?? '';
            //     context.push('/detail-cp-kandang/$id').then((_) {
            //       _fetchData(isRefresh: true);
            //     });
            //   },
            // ),

            const SizedBox(height: 12),
          ] else if (!_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Gagal memuat data peternakan."),
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
              greeting: 'Panel Kontrol Perkebunan'),
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
                                _buildSawiContent(),
                                _buildMelonContent(),
                                _buildAnggurContent(),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_kebun_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_kandang_screen.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_gejala_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_ternak_screen.dart';
import 'package:smart_farming_app/service/sensor_cp.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/model/Ayam.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/menus.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/menu_card.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';

class HomeScreenPetugas extends StatefulWidget {
  const HomeScreenPetugas({super.key});

  @override
  State<HomeScreenPetugas> createState() => _HomeScreenPetugasState();
}

class _HomeScreenPetugasState extends State<HomeScreenPetugas> {
  final DashboardService _dashboardService = DashboardService();
  final SensorService _sensorService = SensorService();
  final LaporanService _laporanService = LaporanService();
  Map<String, dynamic>? _perkebunanData;
  Map<String, dynamic>? _peternakanData;
  Map<String, dynamic>? _sensorMelonData;
  List<dynamic> _ayamPenurunan = [];
  bool _isLoading = true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPerkebunanKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPeternakanKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchData(isRefresh: false);
  }

  Future<void> _fetchData({isRefresh = false}) async {
    if (isRefresh && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        _dashboardService.getDashboardPerkebunan(),
        _dashboardService.getDashboardPeternakan(),
      ]);

      // Fetch sensor data separately (may fail independently)
      Map<String, dynamic>? sensorData;
      try {
        sensorData = await _sensorService.getLatestSensor(SensorType.melon);
      } catch (_) {
        // Sensor data fetch failed, continue with null
      }

      // Fetch penurunan produktivitas & riwayat sakit
      List<dynamic> penurunanDataList = [];
      try {
        final daftarUnit = results[1]?['daftarUnit'] as List<dynamic>?;
        final unitId = (daftarUnit != null && daftarUnit.isNotEmpty)
            ? daftarUnit[0]['id']
            : 'ad917d8c-531e-4867-90d7-8bfedf5e1c3a';
        final penurunanRes = await _laporanService
            .getAyamPenurunanProduktivitas(unitBudidayaId: unitId);
        final riwayatRes =
            await _laporanService.getRiwayatLaporanAyamSakit(unitId);

        final Map<String, String> sickIds = {};
        if (riwayatRes['status'] == true) {
          final List<dynamic> riwayat = riwayatRes['data'] ?? [];
          for (final laporan in riwayat) {
            final List<dynamic> objekList = laporan['objekBudidayaList'] ?? [];
            final String status = laporan['Sakit']?['status'] ?? '';
            for (final objek in objekList) {
              final String id = objek['id']?.toString() ?? '';
              if (id.isNotEmpty) {
                final currentStatus = sickIds[id];
                if (currentStatus == null) {
                  sickIds[id] = status;
                } else if (currentStatus == 'Sembuh' ||
                    currentStatus == 'Sudah ditangani') {
                  sickIds[id] = status;
                } else if (currentStatus == 'Pemantauan' &&
                    (status == 'Belum Ditangani' ||
                        status == 'Belum ditangani' ||
                        status.isEmpty)) {
                  sickIds[id] = status;
                }
              }
            }
          }
        }

        if (penurunanRes['status'] == true) {
          penurunanDataList = penurunanRes['data'] as List<dynamic>? ?? [];
        }
      } catch (_) {
        // Ignored
      }

      if (!mounted) return;
      setState(() {
        _perkebunanData = results[0];
        _peternakanData = results[1];
        _sensorMelonData = sensorData;
        _ayamPenurunan = penurunanDataList;
        _isLoading = false;
      });
      debugPrint('ayam penurunan: ${_ayamPenurunan.length}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          if (_pageController.page?.round() != _selectedTabIndex) {
            _pageController.jumpToPage(_selectedTabIndex);
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Perkebunan',
    'Peternakan',
  ];
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPerkebunanContent() {
    if (_isLoading && _perkebunanData == null) {
      return const Center(child: CircularProgressIndicator());
    }
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
              onPressed: () => _fetchData(isRefresh: true),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

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
            const SizedBox(height: 12),
            DashboardGrid(
              title: 'Kondisi Kebun Saat Ini',
              type: DashboardGridType.basic,
              items: [
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _sensorMelonData?['temperature']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Kelembapan (%)',
                  value: _sensorMelonData?['humidity']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: blue3,
                  iconColor: blue1,
                ),
              ],
              crossAxisCount: 2,
              valueFontSize: 50,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth / 2) - 24;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: MenuCard(
                          key: const Key('pelaporan_harian_perkebunan'),
                          bgColor: yellow1,
                          iconColor: yellow,
                          icon: Icons.add,
                          title: 'Pelaporan Harian',
                          subtitle:
                              'Pelaporan rutin kondisi tanaman setiap hari',
                          onTap: () {
                            context
                                .push('/pilih-kebun',
                                    extra: const PilihKebunScreen(
                                      greeting: "Pelaporan Harian",
                                      tipe: "harian",
                                    ))
                                .then((_) {
                              _fetchData(isRefresh: true);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: MenuCard(
                          key: const Key('pelaporan_khusus_perkebunan'),
                          bgColor: red2,
                          iconColor: green1,
                          icon: Icons.edit,
                          title: 'Pelaporan Khusus',
                          subtitle:
                              'Pelaporan khusus kondisi tanaman seperti sakit, mati, atau panen',
                          onTap: () {
                            context.push('/pelaporan-khusus-tanaman').then((_) {
                              _fetchData(isRefresh: true);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            MenuGrid(
              title: 'Menu Aplikasi Perkebunan',
              menuItems: [
                MenuItem(
                  title: 'Manajamen Kebun',
                  icon: 'set/hydroponics-filled.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-kebun').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajamen Jenis Tanaman',
                  icon: 'set/appleSeed-filled.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () =>
                      context.push('/manajemen-jenis-tanaman').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajamen Komoditas',
                  icon: 'set/fruitbag-filled.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-komoditas').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Hama Kebun',
                  icon: 'set/slugEating-filled.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () => context.push('/laporan-hama'),
                ),
                MenuItem(
                  title: 'Panel Kontrol',
                  icon: 'set/control-panel.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () =>
                      context.push('/dashboard-cp-perkebunan').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NewestReports(
              key: const Key('aktivitas_terbaru_perkebunan'),
              title: 'Aktivitas Terbaru',
              reports:
                  (_perkebunanData?['aktivitasTerbaru'] as List<dynamic>? ?? [])
                      .map((aktivitas) => {
                            'text': aktivitas['judul'] ?? '-',
                            'time': aktivitas['createdAt'],
                            'icon': aktivitas['userAvatarUrl'] ?? '-',
                            'tipe': aktivitas['tipe'] ?? 'unknown',
                            'jenisBudidaya':
                                aktivitas['jenisBudidayaTipe'] ?? 'unknown',
                            'id': aktivitas['id'],
                          })
                      .toList(),
              onViewAll: () => context.push('/riwayat-aktivitas').then((_) {
                _fetchData(isRefresh: true);
              }),
              onItemTap: (context, item) {
                navigateToDetailLaporan(context,
                    idLaporan: item['id'],
                    jenisLaporan: item['tipe'],
                    jenisBudidaya: item['jenisBudidaya']);
              },
              mode: NewestReportsMode.full,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium12.copyWith(color: dark1),
              timeTextStyle: regular12.copyWith(color: dark2),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftar_kebun_perkebunan'),
              title: 'Daftar Kebun',
              items: (_perkebunanData?['daftarKebun'] as List<dynamic>? ?? [])
                  .map((kebun) => {
                        'id': kebun['id'],
                        'name': kebun['nama'],
                        'category': kebun['JenisBudidaya']['nama'],
                        'icon': kebun['gambar'],
                      })
                  .toList(),
              type: 'basic',
              onItemTap: (context, item) {
                final id = item['id'] ?? '';
                context.push('/detail-kebun/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              onViewAll: () => context.push('/manajemen-kebun').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftar_tanaman_perkebunan'),
              title: 'Daftar Jenis Tanaman',
              items: (_perkebunanData?['daftarTanaman'] as List<dynamic>? ?? [])
                  .map((tanaman) => {
                        'id': tanaman['id'],
                        'name': tanaman['nama'],
                        'isActive': tanaman['status'],
                        'icon': tanaman['gambar'],
                      })
                  .toList(),
              type: 'basic',
              onItemTap: (context, item) {
                final id = item['id'] ?? '';
                context.push('/detail-tanaman/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              onViewAll: () =>
                  context.push('/manajemen-jenis-tanaman').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftar_komoditas_perkebunan'),
              title: 'Daftar Komoditas',
              items:
                  (_perkebunanData?['daftarKomoditas'] as List<dynamic>? ?? [])
                      .map((komoditas) => {
                            'id': komoditas['id'],
                            'name': komoditas['nama'],
                            'category': komoditas['JenisBudidaya']['nama'],
                            'icon': komoditas['gambar'],
                          })
                      .toList(),
              type: 'basic',
              onViewAll: () => context.push('/manajemen-komoditas').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 80),
          ] else if (!_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Gagal memuat data perkebunan.",
                        style: regular12.copyWith(color: dark2),
                        key: const Key('no_data_found')),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: const Key('retry_button_perkebunan'),
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

  Widget _buildPeternakanContent() {
    if (_isLoading && _peternakanData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isLoading && _peternakanData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Gagal memuat data peternakan.",
                style: regular12.copyWith(color: dark2),
                key: const Key('no_data_found_peternakan')),
            const SizedBox(height: 10),
            ElevatedButton(
              key: const Key('retry_button_peternakan'),
              onPressed: () => _fetchData(isRefresh: true),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorPeternakanKey,
      onRefresh: () => _fetchData(isRefresh: true),
      color: green1,
      backgroundColor: white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (_peternakanData != null) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth / 2) - 24;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: MenuCard(
                          key: const Key('pelaporan_harian_peternakan'),
                          bgColor: yellow1,
                          iconColor: yellow,
                          icon: Icons.add,
                          title: 'Pelaporan Harian',
                          subtitle:
                              'Pelaporan rutin kondisi ternak setiap hari',
                          onTap: () {
                            context
                                .push('/pilih-kandang',
                                    extra: const PilihKandangScreen(
                                      greeting: "Pelaporan Harian",
                                      tipe: "harian",
                                    ))
                                .then((_) {
                              _fetchData(isRefresh: true);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: MenuCard(
                          key: const Key('pelaporan_khusus_peternakan'),
                          bgColor: red2,
                          iconColor: red,
                          icon: Icons.edit,
                          title: 'Pelaporan Khusus',
                          subtitle:
                              'Pelaporan khusus kondisi ternak seperti sakit, mati, atau panen',
                          onTap: () {
                            context.push('/pelaporan-khusus-ternak').then((_) {
                              _fetchData(isRefresh: true);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            MenuGrid(
              title: 'Menu Aplikasi Peternakan',
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              menuItems: [
                MenuItem(
                  title: 'Manajemen Kandang',
                  icon: 'set/farm-filled.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-kandang').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Jenis Ternak',
                  icon: 'set/chicken-filled.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-ternak').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Komoditas',
                  icon: 'set/dozenEggs-filled.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-komoditas').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Panel Kontrol',
                  icon: 'set/control-panel.png',
                  backgroundColor: green1,
                  iconColor: Colors.white,
                  onTap: () =>
                      context.push('/dashboard-cp-peternakan').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NewestReports(
              key: const Key('ayam_penurunan_produktivitas'),
              title: 'Ayam Penurunan Produktivitas',
              reports: [
                {
                  'id': 'penurunan-all',
                  'text': _ayamPenurunan.isNotEmpty 
                      ? _ayamPenurunan
                          .map((ayam) =>
                              getAyamLabelFromNamaId(ayam['namaId'] ?? ''))
                          .join(', ')
                      : 'Data Kosong (Belum ada penurunan)',
                  'time': _ayamPenurunan.isNotEmpty 
                      ? _ayamPenurunan.first['createdAt'] 
                      : DateTime.now().toIso8601String(),
                  'subtext': _ayamPenurunan.isNotEmpty 
                      ? 'Terdapat ${_ayamPenurunan.length} ekor ayam yang mengalami penurunan produktivitas'
                      : 'Tidak ada data ayam yang mengalami penurunan',
                  'icon': 'assets/icons/set/chicken-filled.png',
                    'tipe': 'penurunan-produktivitas',
                    'isActive': true,
                  }
                ],
                onItemTap: (context, item) {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: const Text('Diagnosa masing-masing'),
                                onTap: () {
                                  Navigator.pop(context);
                                  context
                                      .push('/pilih-ternak',
                                          extra: PilihTernakScreen(
                                            greeting: "Pelaporan Penyakit Ayam",
                                            tipe: "sakit",
                                            data: {
                                              'unitBudidaya': {
                                                'id': (_peternakanData?['daftarUnit'] as List<dynamic>?)?.isNotEmpty == true
                                                    ? _peternakanData!['daftarUnit'][0]['id']
                                                    : 'ad917d8c-531e-4867-90d7-8bfedf5e1c3a'
                                              },
                                              'overrideListTernak':
                                                  _ayamPenurunan,
                                              'lockedGejalaName':
                                                  'produksi telur menurun',
                                            },
                                          ))
                                      .then((_) {
                                    _fetchData(isRefresh: true);
                                  });
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.group),
                                title: const Text('Diagnosa sekaligus'),
                                onTap: () {
                                  Navigator.pop(context);
                                  context
                                      .push('/pilih-gejala',
                                          extra: PilihGejalaScreen(
                                            greeting: "Pelaporan Penyakit Ayam",
                                            tipe: "sakit",
                                            step: 1,
                                            data: {
                                              'unitBudidaya': {
                                                'id': (_peternakanData?['daftarUnit'] as List<dynamic>?)?.isNotEmpty == true
                                                    ? _peternakanData!['daftarUnit'][0]['id']
                                                    : 'ad917d8c-531e-4867-90d7-8bfedf5e1c3a'
                                              },
                                              'objekBudidaya': _ayamPenurunan,
                                              'selectedAyamIds': _ayamPenurunan
                                                  .map((a) => a['id'])
                                                  .toList(),
                                              'lockedGejalaName':
                                                  'produksi telur menurun',
                                            },
                                          ))
                                      .then((_) {
                                    _fetchData(isRefresh: true);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      });
                },
              ),
              const SizedBox(height: 12),
            NewestReports(
              key: const Key('aktivitas_terbaru_peternakan'),
              title: 'Aktivitas Terbaru',
              reports:
                  (_peternakanData?['aktivitasTerbaru'] as List<dynamic>? ?? [])
                      .map((aktivitas) => {
                            'id': aktivitas['id'],
                            'text': aktivitas['judul'] ?? '-',
                            'time': aktivitas['createdAt'],
                            'icon': aktivitas['userAvatarUrl'] ?? '-',
                            'tipe': aktivitas['tipe'] ?? 'unknown',
                            'jenisBudidaya':
                                aktivitas['jenisBudidayaTipe'] ?? 'unknown',
                          })
                      .toList(),
              onViewAll: () => context.push('/riwayat-aktivitas').then((_) {
                _fetchData(isRefresh: true);
              }),
              onItemTap: (context, item) {
                navigateToDetailLaporan(context,
                    idLaporan: item['id'],
                    jenisLaporan: item['tipe'],
                    jenisBudidaya: item['jenisBudidaya']);
              },
              mode: NewestReportsMode.full,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium12.copyWith(color: dark1),
              timeTextStyle: regular12.copyWith(color: dark2),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftar_kandang_peternakan'),
              title: 'Daftar Kandang',
              items: (_peternakanData?['daftarKandang'] as List<dynamic>? ?? [])
                  .map((kandang) => {
                        'id': kandang['id'],
                        'name': kandang['nama'],
                        'category': kandang['JenisBudidaya']['nama'],
                        'icon': kandang['gambar'],
                      })
                  .toList(),
              type: 'basic',
              onItemTap: (context, item) {
                final id = item['id'] ?? '';
                context.push('/detail-kandang/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              onViewAll: () => context.push('/manajemen-kandang').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftar_ternak_peternakan'),
              title: 'Daftar Jenis Ternak',
              items: (_peternakanData?['daftarTernak'] as List<dynamic>? ?? [])
                  .map((ternak) => {
                        'id': ternak['id'],
                        'name': ternak['nama'],
                        'isActive': ternak['status'],
                        'icon': ternak['gambar'],
                      })
                  .toList(),
              type: 'basic',
              onItemTap: (context, item) {
                final id = item['id'] ?? '';
                context.push('/detail-ternak/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              onViewAll: () => context.push('/manajemen-ternak').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftar_komoditas_peternakan'),
              title: 'Daftar Komoditas',
              items:
                  (_peternakanData?['daftarKomoditas'] as List<dynamic>? ?? [])
                      .map((komoditas) => {
                            'id': komoditas['id'],
                            'name': komoditas['nama'],
                            'category': komoditas['JenisBudidaya']['nama'],
                            'icon': komoditas['gambar'],
                          })
                      .toList(),
              type: 'basic',
              onViewAll: () => context.push('/manajemen-komoditas').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 80),
          ] else if (!_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Gagal memuat data peternakan.",
                        style: regular12.copyWith(color: dark2),
                        key: const Key('no_data_found_peternakan')),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: const Key('retry_button_peternakan'),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 0,
              titleSpacing: 0,
              toolbarHeight: 80,
              title: const Header(headerType: HeaderType.basic)),
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
                          const SliverToBoxAdapter(
                            child: BannerWidget(
                              title:
                                  'Kelola Perkebunan dan Peternakan dengan FarmCenter.',
                              subtitle:
                                  'Pantau, lapor, dan tingkatkan hasil panen produk budidaya mu!',
                              showDate: true,
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                              Container(
                                color: Colors.white,
                                child: Tabs(
                                  key: const Key('home_tabs'),
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
                                _buildPeternakanContent(),
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

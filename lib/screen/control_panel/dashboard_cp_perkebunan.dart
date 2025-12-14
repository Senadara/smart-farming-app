import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/service/sensor_cp.dart';
import 'package:smart_farming_app/widget/sensor_line_chart.dart';
import 'package:smart_farming_app/theme/telkom_theme.dart';

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
  List<SensorHistoryData> _sensorHistory = [];
  SensorChartType _selectedChartType = SensorChartType.npk;

  bool _isLoading = true;

  // ===============================
  // 🔄 REFRESH INDICATOR
  // ===============================
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
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
        _hamaService.getLaporanHama(),
        // 📡 SENSOR (AUTO TOKEN)
        _sensorService.getLatestSensor(),
        // 📈 SENSOR HISTORY
        _sensorService.getSensorHistory(),
      ]);

      if (!mounted) return;

      final perkebunan = results[0] as Map<String, dynamic>;
      final sensorData = results[2] as Map<String, dynamic>;
      final historyData = results[3] as List<Map<String, dynamic>>;

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
        // Parse history data
        _sensorHistory =
            historyData.map((e) => SensorHistoryData.fromJson(e)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      showAppToast(
        context,
        'Terjadi kesalahan: $e. Silakan coba lagi',
        title: 'Error Tidak Terduga 😢',
      );
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getChartTitle() {
    switch (_selectedChartType) {
      case SensorChartType.npk:
        return 'Grafik NPK (mg/kg)';
      case SensorChartType.environment:
        return 'Grafik Suhu & Kelembaban';
      case SensorChartType.soil:
        return 'Grafik EC & pH';
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
          title: const Header(
            headerType: HeaderType.back,
            title: 'Kontrol Panel Melon',
            greeting: 'Data Sensor IoT',
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMelonContent(),
    );
  }

  Widget _buildMelonContent() {
    if (!_isLoading && _perkebunanData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Gagal memuat data sensor."),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _fetchData(isRefresh: true),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    // Format timestamp if available
    String lastUpdate = '-';
    if (_perkebunanData?['createdAt'] != null) {
      try {
        final dt = DateTime.parse(_perkebunanData!['createdAt']);
        lastUpdate = DateFormat('dd MMM yyyy, HH:mm').format(dt);
      } catch (_) {}
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => _fetchData(isRefresh: true),
      color: green1,
      backgroundColor: white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          if (_perkebunanData != null) ...[
            // Last update indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: TelkomColors.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 16, color: TelkomColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Update terakhir: $lastUpdate',
                    style:
                        regular12.copyWith(color: TelkomColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // IoT Sensor Grid - Environment
            DashboardGrid(
              title: 'Data Sensor Lingkungan',
              items: [
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _perkebunanData?['suhu']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Kelembaban (%)',
                  value: _perkebunanData?['humidity']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
              ],
              crossAxisCount: 2,
              valueFontSize: 40,
            ),
            const SizedBox(height: 16),

            // IoT Sensor Grid - NPK
            DashboardGrid(
              title: 'Data Sensor NPK (mg/kg)',
              items: [
                DashboardItem(
                  title: 'Nitrogen (N)',
                  value: _perkebunanData?['nitrogen']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Phosphor (P)',
                  value: _perkebunanData?['phosphor']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Potassium (K)',
                  value: _perkebunanData?['potassium']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
              ],
              crossAxisCount: 3,
              valueFontSize: 32,
              titleFontSize: 13.5,
              paddingSize: 12.5,
              iconsWidth: 36,
            ),
            const SizedBox(height: 16),

            // IoT Sensor Grid - Soil
            DashboardGrid(
              title: 'Data Sensor Tanah',
              items: [
                DashboardItem(
                  title: 'EC (mS/cm)',
                  value: _perkebunanData?['ec']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'pH Level',
                  value: _perkebunanData?['ph']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
              ],
              crossAxisCount: 2,
              valueFontSize: 40,
            ),
            const SizedBox(height: 24),

            // History Chart Section
            Text(
              'Histori Sensor',
              style: bold18.copyWith(color: dark1),
            ),
            const SizedBox(height: 12),

            // Chart Type Selector
            ChartTypeSelector(
              selectedType: _selectedChartType,
              onChanged: (type) {
                setState(() {
                  _selectedChartType = type;
                });
              },
            ),
            const SizedBox(height: 16),

            // Interactive Line Chart
            SensorLineChart(
              data: _sensorHistory,
              title: _getChartTitle(),
              chartType: _selectedChartType,
              height: 280,
            ),
            const SizedBox(height: 24),
          ] else if (!_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Gagal memuat data sensor."),
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
}

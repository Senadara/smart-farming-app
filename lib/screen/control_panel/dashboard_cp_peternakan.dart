import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/service/sensor_cp.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/ayam_sensor_chart.dart';
import 'package:smart_farming_app/theme/telkom_theme.dart';

class DashboardCpPeternakan extends StatefulWidget {
  const DashboardCpPeternakan({super.key});

  @override
  State<DashboardCpPeternakan> createState() => _DashboardCpPeternakanState();
}

class _DashboardCpPeternakanState extends State<DashboardCpPeternakan> {
  final DashboardService _dashboardService = DashboardService();
  final SensorService _sensorService = SensorService();

  Map<String, dynamic>? _peternakanData;
  List<AyamSensorData> _sensorHistory = [];

  bool _isLoading = true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchData(isRefresh: false);
  }

  Future<void> _fetchData({bool isRefresh = false}) async {
    if (!isRefresh && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        _dashboardService.getDashboardPeternakan(),
        // 📡 SENSOR AYAM (temperature & humidity only)
        _sensorService.getLatestSensor(SensorType.ayam),
        // 📈 SENSOR HISTORY
        _sensorService.getSensorHistory(SensorType.ayam),
      ]);

      if (!mounted) return;

      final peternakan = results[0] as Map<String, dynamic>;
      final sensorData = results[1] as Map<String, dynamic>;
      final historyData = results[2] as List<Map<String, dynamic>>;

      setState(() {
        _peternakanData = {
          ...peternakan,
          'suhu': sensorData['temperature'],
          'humidity': sensorData['humidity'],
          'createdAt': sensorData['createdAt'],
        };
        // Parse history data for ayam (only temperature & humidity)
        _sensorHistory =
            historyData.map((e) => AyamSensorData.fromJson(e)).toList();
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
            title: 'Kontrol Panel Ayam',
            greeting: 'Data Sensor IoT',
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAyamContent(),
    );
  }

  Widget _buildAyamContent() {
    if (!_isLoading && _peternakanData == null) {
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
    if (_peternakanData?['createdAt'] != null) {
      try {
        final dt = DateTime.parse(_peternakanData!['createdAt']);
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
          if (_peternakanData != null) ...[
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

            // IoT Sensor Grid - Environment (Temperature & Humidity only)
            DashboardGrid(
              title: 'Data Sensor Kandang Ayam',
              items: [
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _peternakanData?['suhu']?.toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Kelembaban (%)',
                  value: _peternakanData?['humidity']?.toString() ?? '-',
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
            const SizedBox(height: 16),

            // Interactive Line Chart for Ayam (Temperature & Humidity)
            AyamSensorChart(
              data: _sensorHistory,
              title: 'Grafik Suhu & Kelembaban',
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

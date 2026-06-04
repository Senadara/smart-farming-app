import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';

class ChartComparison extends StatefulWidget {
  final String? unitBudidayaId;
  final int? year;

  const ChartComparison({super.key, this.unitBudidayaId, this.year});

  @override
  State<ChartComparison> createState() => _ChartComparisonState();
}

class _ChartComparisonState extends State<ChartComparison> {
  final LaporanService _laporanService = LaporanService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _chartData = [];
  int _year = DateTime.now().year;

  // Colors for lines
  final List<Color> _lineColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _laporanService.getStatistikPenyakitAyam(
      unitBudidayaId: widget.unitBudidayaId,
      year: widget.year,
    );

    if (response['status'] == true) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _year = response['year'] ?? DateTime.now().year;
          _chartData = List<Map<String, dynamic>>.from(response['data'] ?? []);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = response['message'] ?? 'Gagal memuat data';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              TextButton(
                onPressed: _fetchData,
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    if (_chartData.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('Tidak ada data statistik penyakit')),
      );
    }

    // Prepare line chart data
    List<LineChartBarData> lineBars = [];
    List<Widget> legendItems = [];

    for (int i = 0; i < _chartData.length; i++) {
      final diseaseName = _chartData[i]['name'] as String;
      final rawDataList = _chartData[i]['data'] as List<dynamic>;
      final color = _lineColors[i % _lineColors.length];

      // Build spots
      List<FlSpot> spots = [];
      for (int j = 0; j < rawDataList.length; j++) {
        spots.add(FlSpot(j.toDouble(), (rawDataList[j] as num).toDouble()));
      }

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
      );

      legendItems.add(_legendItem(color, diseaseName));
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perbandingan Tren Penyakit Tahun $_year',
              style: bold16.copyWith(color: dark1),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                            'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                          ];
                          int index = value.toInt();
                          if (index < 0 || index >= months.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[index],
                              style: regular12.copyWith(color: dark2),
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  lineBarsData: lineBars,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: legendItems,
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: regular12.copyWith(color: dark2)),
      ],
    );
  }
}

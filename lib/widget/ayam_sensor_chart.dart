import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/theme/telkom_theme.dart';

/// Data model for Ayam sensor (temperature & humidity only)
class AyamSensorData {
  final DateTime timestamp;
  final double temperature;
  final double humidity;

  AyamSensorData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
  });

  factory AyamSensorData.fromJson(Map<String, dynamic> json) {
    return AyamSensorData(
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
    );
  }
}

/// Interactive line chart widget for Ayam sensor history (temperature & humidity)
class AyamSensorChart extends StatelessWidget {
  final List<AyamSensorData> data;
  final String title;
  final double height;

  const AyamSensorChart({
    super.key,
    required this.data,
    required this.title,
    this.height = 250,
  });

  static const List<Color> _lineColors = [
    Color(0xFFFF9306), // Temperature - Orange
    Color(0xFF37B7FF), // Humidity - Light Blue
  ];

  static const List<String> _lineLabels = ['Suhu (°C)', 'Kelembaban (%)'];

  /// Sort data by timestamp ascending (oldest first on left, newest on right)
  List<AyamSensorData> get _sortedData {
    final sorted = List<AyamSensorData>.from(data);
    sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted;
  }

  List<List<FlSpot>> _generateSpots() {
    final sorted = _sortedData;
    return [
      sorted.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.temperature)).toList(),
      sorted.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.humidity)).toList(),
    ];
  }

  double _getMaxY() {
    double maxVal = 0;
    for (var item in data) {
      if (item.temperature > maxVal) maxVal = item.temperature;
      if (item.humidity > maxVal) maxVal = item.humidity;
    }
    return maxVal * 1.2; // Add 20% padding
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: bold16.copyWith(color: dark1)),
            const Expanded(
              child: Center(
                child: Text('Tidak ada data historis', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      );
    }

    final sortedData = _sortedData;
    final spots = _generateSpots();
    final maxY = _getMaxY();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: bold16.copyWith(color: dark1)),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: List.generate(_lineLabels.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _lineColors[index],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _lineLabels[index],
                      style: regular12.copyWith(color: dark2),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height - 100,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxY / 5,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: regular10.copyWith(color: dark3),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: sortedData.length > 6 ? (sortedData.length / 6).ceil().toDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedData.length) {
                          return const SizedBox.shrink();
                        }
                        final timestamp = sortedData[index].timestamp;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('HH:mm').format(timestamp),
                            style: regular10.copyWith(color: dark3),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (sortedData.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => TelkomColors.textPrimary.withValues(alpha: 0.9),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(12),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final colorIndex = spot.barIndex;
                        return LineTooltipItem(
                          '${_lineLabels[colorIndex]}: ${spot.y.toStringAsFixed(1)}',
                          TextStyle(
                            color: _lineColors[colorIndex],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                lineBarsData: List.generate(spots.length, (index) {
                  return LineChartBarData(
                    spots: spots[index],
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: _lineColors[index],
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, dotIndex) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: _lineColors[index],
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _lineColors[index].withValues(alpha: 0.3),
                          _lineColors[index].withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  );
                }),
              ),
              duration: const Duration(milliseconds: 500),
            ),
          ),
        ],
      ),
    );
  }
}

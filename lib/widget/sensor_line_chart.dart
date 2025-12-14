import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/theme/telkom_theme.dart';

/// Data model for sensor history chart
class SensorHistoryData {
  final DateTime timestamp;
  final double nitrogen;
  final double phosphor;
  final double potassium;
  final double temperature;
  final double humidity;
  final double ec;
  final double ph;

  SensorHistoryData({
    required this.timestamp,
    required this.nitrogen,
    required this.phosphor,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.ec,
    required this.ph,
  });

  factory SensorHistoryData.fromJson(Map<String, dynamic> json) {
    return SensorHistoryData(
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      nitrogen: (json['nitrogen'] ?? 0).toDouble(),
      phosphor: (json['phosphor'] ?? 0).toDouble(),
      potassium: (json['potassium'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      ec: (json['ec'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
    );
  }
}

/// Interactive line chart widget for sensor history
class SensorLineChart extends StatefulWidget {
  final List<SensorHistoryData> data;
  final String title;
  final SensorChartType chartType;
  final double height;

  const SensorLineChart({
    super.key,
    required this.data,
    required this.title,
    required this.chartType,
    this.height = 250,
  });

  @override
  State<SensorLineChart> createState() => _SensorLineChartState();
}

enum SensorChartType { npk, environment, soil }

class _SensorLineChartState extends State<SensorLineChart> {
  int? touchedIndex;

  List<Color> get _lineColors {
    switch (widget.chartType) {
      case SensorChartType.npk:
        return [
          TelkomColors.primary, // Nitrogen - Red
          const Color(0xFF00A676), // Phosphor - Green
          const Color(0xFF177BFF), // Potassium - Blue
        ];
      case SensorChartType.environment:
        return [
          const Color(0xFFFF9306), // Temperature - Orange
          const Color(0xFF37B7FF), // Humidity - Light Blue
        ];
      case SensorChartType.soil:
        return [
          const Color(0xFF87027B), // EC - Purple
          const Color(0xFF3B9C0B), // pH - Green
        ];
    }
  }

  List<String> get _lineLabels {
    switch (widget.chartType) {
      case SensorChartType.npk:
        return ['Nitrogen', 'Phosphor', 'Potassium'];
      case SensorChartType.environment:
        return ['Suhu (°C)', 'Kelembaban (%)'];
      case SensorChartType.soil:
        return ['EC (mS/cm)', 'pH'];
    }
  }

  List<List<FlSpot>> _generateSpots() {
    switch (widget.chartType) {
      case SensorChartType.npk:
        return [
          widget.data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.nitrogen)).toList(),
          widget.data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.phosphor)).toList(),
          widget.data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.potassium)).toList(),
        ];
      case SensorChartType.environment:
        return [
          widget.data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.temperature)).toList(),
          widget.data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.humidity)).toList(),
        ];
      case SensorChartType.soil:
        return [
          widget.data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.ec)).toList(),
          widget.data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.ph)).toList(),
        ];
    }
  }

  double _getMaxY() {
    double maxVal = 0;
    final spots = _generateSpots();
    for (var spotList in spots) {
      for (var spot in spotList) {
        if (spot.y > maxVal) maxVal = spot.y;
      }
    }
    return maxVal * 1.2; // Add 20% padding
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Container(
        height: widget.height,
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
            Text(widget.title, style: bold16.copyWith(color: dark1)),
            const Expanded(
              child: Center(
                child: Text('Tidak ada data historis', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      );
    }

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
          Text(widget.title, style: bold16.copyWith(color: dark1)),
          const SizedBox(height: 8),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(_lineLabels.length, (index) {
              return Row(
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
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: widget.height - 100,
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
                      interval: widget.data.length > 6 ? (widget.data.length / 6).ceil().toDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= widget.data.length) {
                          return const SizedBox.shrink();
                        }
                        final timestamp = widget.data[index].timestamp;
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
                maxX: (widget.data.length - 1).toDouble(),
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
                        final barIndex = spots.indexWhere((s) => identical(s, barData.spots));
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: _lineColors[barIndex >= 0 ? barIndex : 0],
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

/// Chip selector for chart types
class ChartTypeSelector extends StatelessWidget {
  final SensorChartType selectedType;
  final ValueChanged<SensorChartType> onChanged;

  const ChartTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip('NPK', SensorChartType.npk),
        const SizedBox(width: 8),
        _buildChip('Lingkungan', SensorChartType.environment),
        const SizedBox(width: 8),
        _buildChip('Tanah', SensorChartType.soil),
      ],
    );
  }

  Widget _buildChip(String label, SensorChartType type) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TelkomColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TelkomColors.primary : TelkomColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TelkomColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: semibold12.copyWith(
            color: isSelected ? Colors.white : dark2,
          ),
        ),
      ),
    );
  }
}

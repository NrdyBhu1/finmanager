import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'finance_provider.dart';
import 'transaction.dart';
import 'sheets.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'finance_provider.dart';

class MonthlyDebitChart extends StatefulWidget {
  const MonthlyDebitChart({super.key});

  @override
  State<MonthlyDebitChart> createState() => _MonthlyDebitChartState();
}

class _MonthlyDebitChartState extends State<MonthlyDebitChart> {
  // Use your theme colors
  late List<Color> gradientColors;

  bool showAvg = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize colors here to access the theme if needed, 
    // or use your constant definitions.
    gradientColors = [
      accentGreen,
      lighten(accentGreen, 0.2), // Uses your lighten helper
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final dailyDebitData = provider.monthlyDebitDataByDay;

    List<FlSpot> chartSpots = dailyDebitData.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    chartSpots.sort((a, b) => a.x.compareTo(b.x));

    final maxAmount = chartSpots.isEmpty ? 1.0 : chartSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final avgAmount = chartSpots.isEmpty ? 0.0 : chartSpots.map((s) => s.y).reduce((a, b) => a + b) / chartSpots.length;
    final maxX = dailyDebitData.keys.isEmpty ? 31.0 : dailyDebitData.keys.reduce((a, b) => a > b ? a : b).toDouble();

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              color: primaryDarkBackground, // Aligned with your theme
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
              child: LineChart(
                showAvg 
                  ? avgData(chartSpots, maxX, maxAmount, avgAmount) 
                  : mainData(chartSpots, maxX, maxAmount),
              ),
            ),
          ),
        ),
        // Average Toggle Button - Styled to match your theme
        Positioned(
          top: 0,
          left: 0,
          child: TextButton(
            onPressed: () => setState(() => showAvg = !showAvg),
            child: Text(
              'AVG',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: showAvg ? accentGreen : secondaryGray,
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData(List<FlSpot> spots, double maxX, double maxAmount) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false, // Cleaner look
        horizontalInterval: maxAmount / 3 > 0 ? maxAmount / 3 : 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: secondaryGray.withOpacity(0.1), // Subtle grid
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 5,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              meta: meta,
              child: Text(
                '${value.toInt()}', 
                style: const TextStyle(color: secondaryGray, fontSize: 12)
              ),
            ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxAmount / 3 > 0 ? maxAmount / 3 : 1,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: const TextStyle(color: secondaryGray, fontSize: 12),
            ),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: false), // Removed border for modern look
      minX: 1,
      maxX: maxX,
      minY: 0,
      maxY: maxAmount * 1.2,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accentGreen.withOpacity(0.3),
                accentGreen.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData(List<FlSpot> spots, double maxX, double maxAmount, double avg) {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: mainData(spots, maxX, maxAmount).gridData,
      titlesData: mainData(spots, maxX, maxAmount).titlesData,
      borderData: FlBorderData(show: false),
      minX: 1,
      maxX: maxX,
      minY: 0,
      maxY: maxAmount * 1.2,
      lineBarsData: [
        LineChartBarData(
          spots: [FlSpot(1, avg), FlSpot(maxX, avg)],
          isCurved: false,
          barWidth: 2,
          dashArray: [5, 5], // Dashed line for average
          color: secondaryGray,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}

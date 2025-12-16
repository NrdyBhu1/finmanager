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
  // Styling colors inspired by the sample
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final dailyDebitData = provider.monthlyDebitDataByDay;

    // 1. Prepare Data Spots
    List<FlSpot> chartSpots = dailyDebitData.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    // Sort spots by X value to ensure the line draws correctly
    chartSpots.sort((a, b) => a.x.compareTo(b.x));

    // 2. Calculate dynamic bounds and averages
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
              color: Color(0xff232d37), // Dark background from sample
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
        // Average Toggle Button
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () => setState(() => showAvg = !showAvg),
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
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
        drawVerticalLine: true,
        horizontalInterval: maxAmount / 3 > 0 ? maxAmount / 3 : 1,
        verticalInterval: 5, // Grid line every 5 days
        getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xff37434d), strokeWidth: 1),
        getDrawingVerticalLine: (value) => const FlLine(color: Color(0xff37434d), strokeWidth: 1),
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
              child: Text('${value.toInt()}', style: const TextStyle(color: Color(0xff68737d), fontSize: 12)),
            ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxAmount / 3 > 0 ? maxAmount / 3 : 1,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: const TextStyle(color: Color(0xff67727d), fontSize: 12),
            ),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 1,
      maxX: maxX,
      minY: 0,
      maxY: maxAmount * 1.2, // Give some head room
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData(List<FlSpot> spots, double maxX, double maxAmount, double avg) {
    // Create spots for the flat average line
    List<FlSpot> avgSpots = [FlSpot(1, avg), FlSpot(maxX, avg)];

    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: mainData(spots, maxX, maxAmount).gridData,
      titlesData: mainData(spots, maxX, maxAmount).titlesData,
      borderData: mainData(spots, maxX, maxAmount).borderData,
      minX: 1,
      maxX: maxX,
      minY: 0,
      maxY: maxAmount * 1.2,
      lineBarsData: [
        LineChartBarData(
          spots: avgSpots,
          isCurved: false,
          barWidth: 5,
          color: gradientColors[0].withOpacity(0.8),
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: gradientColors[0].withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

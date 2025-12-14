import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'finance_provider.dart';
import 'transaction.dart';
import 'sheets.dart';

class MonthlyDebitChart extends StatelessWidget {
  const MonthlyDebitChart({super.key});

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    
    final day = value.toInt();

    if (day == 1 || day % 5 == 0) {
      return SideTitleWidget(
        meta: meta,
        space: 8.0,
        child: Text('$day', style: style),
      );
    }
    return Container();
  }

  // Inside MonthlyDebitChart class's build method:
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final dailyDebitData = provider.monthlyDebitDataByDay;

    // 1. Data Processing and Setup
    List<FlSpot> chartSpots = dailyDebitData.entries
    .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
    .toList();

    // Calculate boundaries safely
    final maxAmount = chartSpots.map((spot) => spot.y).fold(0.0, (a, b) => a > b ? a : b);
    final maxX = dailyDebitData.keys.fold(31.0, (a, b) => b.toDouble() > a ? b.toDouble() : a); 
    
    // FIX 1 & 2: Safe Boundaries and Interval Calculation
    final safeMaxY = maxAmount > 0 ? maxAmount * 1.1 : 1.0; // If no spending, set max to 1.0
    final yInterval = maxAmount > 0 ? maxAmount / 3 : 1.0; // If no spending, set interval to 1.0

    // 2. The Line Chart configuration
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
        child: LineChart(
          LineChartData(
            // ... (Existing gridData and borderData) ...
            
            titlesData: FlTitlesData(
              // ... (Existing top and right titles) ...

              // Bottom (X-axis) titles remain the same
              bottomTitles: AxisTitles(
                axisNameWidget: const Text('Day of Month', style: TextStyle(fontSize: 12)),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1, 
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
              
              // Left (Y-axis) titles with the fix
              leftTitles: AxisTitles(
                axisNameWidget: const Text('Amount', style: TextStyle(fontSize: 12)),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: yInterval, // <-- NOW USES THE SAFE INTERVAL
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toStringAsFixed(0)}', // Show whole numbers
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            
            // Define the chart boundaries with safeMaxY
            minX: 1, 
            maxX: maxX,
            minY: 0,
            maxY: safeMaxY, // <-- NOW USES THE SAFE MAX Y
            
            lineBarsData: [
              LineChartBarData(
                spots: chartSpots,
                isCurved: true,
                color: Colors.red.shade600,
                barWidth: 3,
                isStrokeCapRound: true,
                // FIX 2 continuation: If no spending, show a single dot/line at 0
                dotData: FlDotData(
                  show: maxAmount > 0, // Only show dots if there is actual spending
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.red.shade600.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

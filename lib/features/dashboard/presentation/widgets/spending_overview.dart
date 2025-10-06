import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingOverview extends StatelessWidget {
  const SpendingOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 26.4,
                    color: const Color(0xFFFF6B6B),
                    title: 'Food',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 13.2,
                    color: const Color(0xFF4ECDC4),
                    title: 'Transport',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 27.4,
                    color: const Color(0xFFFFD93D),
                    title: 'Shopping',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 11.3,
                    color: const Color(0xFFF38181),
                    title: 'Bills',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 21.7,
                    color: const Color(0xFF95A5A6),
                    title: 'Other',
                    radius: 60,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



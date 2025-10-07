import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpendingOverview extends StatelessWidget {
  const SpendingOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Overview',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 26.4,
                    color: const Color(0xFFFF6B6B),
                    title: 'Food',
                    radius: 60.r,
                  ),
                  PieChartSectionData(
                    value: 13.2,
                    color: const Color(0xFF4ECDC4),
                    title: 'Transport',
                    radius: 60.r,
                  ),
                  PieChartSectionData(
                    value: 27.4,
                    color: const Color(0xFFFFD93D),
                    title: 'Shopping',
                    radius: 60.r,
                  ),
                  PieChartSectionData(
                    value: 11.3,
                    color: const Color(0xFFF38181),
                    title: 'Bills',
                    radius: 60.r,
                  ),
                  PieChartSectionData(
                    value: 21.7,
                    color: const Color(0xFF95A5A6),
                    title: 'Other',
                    radius: 60.r,
                  ),
                ],
                sectionsSpace: 2.w,
                centerSpaceRadius: 40.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

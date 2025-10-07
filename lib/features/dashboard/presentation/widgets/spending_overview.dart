import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpendingOverview extends StatefulWidget {
  const SpendingOverview({super.key});

  @override
  State<SpendingOverview> createState() => _SpendingOverviewState();
}

class _SpendingOverviewState extends State<SpendingOverview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Chart data
  final List<SpendingData> _spendingData = [
    SpendingData(value: 26.4, color: const Color(0xFFFF6B6B), title: 'Food'),
    SpendingData(
      value: 13.2,
      color: const Color(0xFF4ECDC4),
      title: 'Transport',
    ),
    SpendingData(
      value: 27.4,
      color: const Color(0xFFFFD93D),
      title: 'Shopping',
    ),
    SpendingData(value: 11.3, color: const Color(0xFFF38181), title: 'Bills'),
    SpendingData(value: 21.7, color: const Color(0xFF95A5A6), title: 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return PieChart(
                  PieChartData(
                    sections: _buildAnimatedSections(),
                    sectionsSpace: 2.w,
                    centerSpaceRadius: 40.r,
                    startDegreeOffset: -90,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildAnimatedSections() {
    return _spendingData.map((data) {
      // Animate from 0 to final value
      final animatedValue = data.value * _animation.value;

      return PieChartSectionData(
        value: animatedValue,
        color: data.color,
        title: _animation.value > 0.7 ? data.title : '',
        radius: 60.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

// Data model for spending categories
class SpendingData {
  final double value;
  final Color color;
  final String title;

  SpendingData({required this.value, required this.color, required this.title});
}

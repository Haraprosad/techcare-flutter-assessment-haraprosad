import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';

class SpendingOverview extends StatefulWidget {
  const SpendingOverview({super.key});

  @override
  State<SpendingOverview> createState() => _SpendingOverviewState();
}

class _SpendingOverviewState extends State<SpendingOverview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

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
    final colors = context.colors;

    // Chart data - using theme colors
    final spendingData = [
      SpendingData(value: 26.4, color: colors.chartColor1, title: 'Food'),
      SpendingData(value: 13.2, color: colors.chartColor2, title: 'Transport'),
      SpendingData(value: 27.4, color: colors.chartColor3, title: 'Shopping'),
      SpendingData(value: 11.3, color: colors.chartColor4, title: 'Bills'),
      SpendingData(value: 21.7, color: colors.chartColor5, title: 'Other'),
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.textSecondary.withOpacity(0.1),
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
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return PieChart(
                  PieChartData(
                    sections: _buildAnimatedSections(spendingData),
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

  List<PieChartSectionData> _buildAnimatedSections(List<SpendingData> data) {
    final colors = context.colors;

    return data.map((item) {
      // Animate from 0 to final value
      final animatedValue = item.value * _animation.value;

      return PieChartSectionData(
        value: animatedValue,
        color: item.color,
        title: _animation.value > 0.7 ? item.title : '',
        radius: 60.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: colors.onPrimaryContainer,
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

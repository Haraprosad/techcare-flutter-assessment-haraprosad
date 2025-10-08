import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/monthly_trend.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';

/// Shows a 6-month line chart of income vs expenses.
///
/// Renders income (green) and expense (red) trends with smooth animations.
/// Great for spotting spending patterns over time.
class SpendingTrendChart extends StatefulWidget {
  final List<MonthlyTrend> trends;

  const SpendingTrendChart({super.key, required this.trends});

  @override
  State<SpendingTrendChart> createState() => _SpendingTrendChartState();
}

class _SpendingTrendChartState extends State<SpendingTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Set up the chart animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Kick off the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    // Find the highest value to scale the chart properly
    final maxValue = widget.trends.fold<double>(
      0,
      (max, trend) =>
          [max, trend.income, trend.expense].reduce((a, b) => a > b ? a : b),
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trend (6 Months)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Legend showing what the colors mean
            Row(
              children: [
                _Legend(color: colors.income, label: 'Income'),
                const SizedBox(width: 16),
                _Legend(color: colors.expense, label: 'Expenses'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return _SimpleLineChart(
                    trends: widget.trends,
                    maxValue: maxValue,
                    animationProgress: _animation.value,
                    incomeColor: colors.income,
                    expenseColor: colors.expense,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<MonthlyTrend> trends;
  final double maxValue;
  final double animationProgress;
  final Color incomeColor;
  final Color expenseColor;

  const _SimpleLineChart({
    required this.trends,
    required this.maxValue,
    required this.animationProgress,
    required this.incomeColor,
    required this.expenseColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        trends: trends,
        maxValue: maxValue,
        incomeColor: incomeColor,
        expenseColor: expenseColor,
        animationProgress: animationProgress,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: trends.map((trend) {
              // Parse month string (format: "2025-04") by adding day
              final month = DateFormat(
                'MMM',
              ).format(DateTime.parse('${trend.month}-01'));
              return Text(month, style: Theme.of(context).textTheme.bodySmall);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<MonthlyTrend> trends;
  final double maxValue;
  final Color incomeColor;
  final Color expenseColor;
  final double animationProgress;

  _LineChartPainter({
    required this.trends,
    required this.maxValue,
    required this.incomeColor,
    required this.expenseColor,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final incomePath = Path();
    final expensePath = Path();

    final spacing = size.width / (trends.length - 1);
    final bottomPadding = 20.0; // Space for month labels

    // Calculate how many points to show based on animation progress
    final totalPoints = trends.length;
    final animatedPointCount = (totalPoints * animationProgress).ceil();

    for (var i = 0; i < animatedPointCount && i < trends.length; i++) {
      final x = i * spacing;
      final incomeY =
          size.height -
          bottomPadding -
          ((trends[i].income / maxValue) * (size.height - bottomPadding));
      final expenseY =
          size.height -
          bottomPadding -
          ((trends[i].expense / maxValue) * (size.height - bottomPadding));

      if (i == 0) {
        incomePath.moveTo(x, incomeY);
        expensePath.moveTo(x, expenseY);
      } else {
        // For the last visible point during animation, interpolate
        if (i == animatedPointCount - 1 && animationProgress < 1.0) {
          final progress =
              (totalPoints * animationProgress) - (animatedPointCount - 1);
          final prevX = (i - 1) * spacing;

          final prevIncomeY =
              size.height -
              bottomPadding -
              ((trends[i - 1].income / maxValue) *
                  (size.height - bottomPadding));
          final prevExpenseY =
              size.height -
              bottomPadding -
              ((trends[i - 1].expense / maxValue) *
                  (size.height - bottomPadding));

          final interpolatedX = prevX + (x - prevX) * progress;
          final interpolatedIncomeY =
              prevIncomeY + (incomeY - prevIncomeY) * progress;
          final interpolatedExpenseY =
              prevExpenseY + (expenseY - prevExpenseY) * progress;

          incomePath.lineTo(interpolatedX, interpolatedIncomeY);
          expensePath.lineTo(interpolatedX, interpolatedExpenseY);

          // Draw interpolated dots
          canvas.drawCircle(
            Offset(interpolatedX, interpolatedIncomeY),
            4,
            Paint()..color = incomeColor,
          );
          canvas.drawCircle(
            Offset(interpolatedX, interpolatedExpenseY),
            4,
            Paint()..color = expenseColor,
          );
        } else {
          incomePath.lineTo(x, incomeY);
          expensePath.lineTo(x, expenseY);

          // Draw dots
          canvas.drawCircle(
            Offset(x, incomeY),
            4,
            Paint()..color = incomeColor,
          );
          canvas.drawCircle(
            Offset(x, expenseY),
            4,
            Paint()..color = expenseColor,
          );
        }
      }
    }

    // Draw the first point immediately
    if (animatedPointCount > 0) {
      final x = 0.0;
      final incomeY =
          size.height -
          bottomPadding -
          ((trends[0].income / maxValue) * (size.height - bottomPadding));
      final expenseY =
          size.height -
          bottomPadding -
          ((trends[0].expense / maxValue) * (size.height - bottomPadding));

      canvas.drawCircle(Offset(x, incomeY), 4, Paint()..color = incomeColor);
      canvas.drawCircle(Offset(x, expenseY), 4, Paint()..color = expenseColor);
    }

    // Draw lines
    canvas.drawPath(incomePath, paint..color = incomeColor);
    canvas.drawPath(expensePath, paint..color = expenseColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

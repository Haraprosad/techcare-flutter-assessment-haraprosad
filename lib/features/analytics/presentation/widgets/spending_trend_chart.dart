import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/monthly_trend.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<MonthlyTrend> trends;

  const SpendingTrendChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = trends.fold<double>(
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
            Row(
              children: [
                _Legend(color: Colors.green, label: 'Income'),
                const SizedBox(width: 16),
                _Legend(color: Colors.red, label: 'Expenses'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _SimpleLineChart(trends: trends, maxValue: maxValue),
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

  const _SimpleLineChart({required this.trends, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactCurrency(symbol: '৳');

    return CustomPaint(
      painter: _LineChartPainter(
        trends: trends,
        maxValue: maxValue,
        incomeColor: Colors.green,
        expenseColor: Colors.red,
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

  _LineChartPainter({
    required this.trends,
    required this.maxValue,
    required this.incomeColor,
    required this.expenseColor,
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

    for (var i = 0; i < trends.length; i++) {
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
        incomePath.lineTo(x, incomeY);
        expensePath.lineTo(x, expenseY);
      }

      // Draw dots
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

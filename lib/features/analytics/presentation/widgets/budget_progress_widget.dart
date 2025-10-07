import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/category_breakdown.dart';

class BudgetProgressWidget extends StatelessWidget {
  final List<CategoryBreakdown> categories;

  const BudgetProgressWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final categoriesWithBudget = categories
        .where((c) => c.budget != null && c.budgetUtilization != null)
        .toList();

    if (categoriesWithBudget.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: categoriesWithBudget
                  .map((category) => _BudgetCircle(category: category))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCircle extends StatelessWidget {
  final CategoryBreakdown category;

  const _BudgetCircle({required this.category});

  Color _parseColor(String colorString) {
    final hexColor = colorString.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  Color _getBudgetStatusColor() {
    final utilization = category.budgetUtilization ?? 0;
    if (utilization <= 70) return Colors.green;
    if (utilization <= 90) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final utilization = (category.budgetUtilization ?? 0).clamp(0.0, 100.0);
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: utilization / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  color: _getBudgetStatusColor(),
                ),
                Text(
                  '${utilization.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.categoryName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${currencyFormat.format(category.amount)} / ${currencyFormat.format(category.budget)}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

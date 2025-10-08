import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/category_breakdown.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';

class BudgetProgressWidget extends StatefulWidget {
  final List<CategoryBreakdown> categories;

  const BudgetProgressWidget({super.key, required this.categories});

  @override
  State<BudgetProgressWidget> createState() => _BudgetProgressWidgetState();
}

class _BudgetProgressWidgetState extends State<BudgetProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    final categoriesWithBudget = widget.categories
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
              children: List.generate(categoriesWithBudget.length, (index) {
                // Staggered animation: each circle starts slightly after the previous one
                final delay = index * 0.15; // 150ms delay between each
                final animation = CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    delay.clamp(0.0, 0.7), // Start time
                    (delay + 0.3).clamp(
                      0.3,
                      1.0,
                    ), // End time (300ms duration per circle)
                    curve: Curves.easeOut,
                  ),
                );

                return _BudgetCircle(
                  category: categoriesWithBudget[index],
                  animation: animation,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCircle extends StatelessWidget {
  final CategoryBreakdown category;
  final Animation<double> animation;

  const _BudgetCircle({required this.category, required this.animation});

  Color _parseColor(String colorString) {
    final hexColor = colorString.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  Color _getBudgetStatusColor(BuildContext context) {
    final utilization = category.budgetUtilization ?? 0;
    final colors = context.colors;
    if (utilization <= 70) return colors.success;
    if (utilization <= 90) return colors.warning;
    return colors.expense;
  }

  @override
  Widget build(BuildContext context) {
    final utilization = (category.budgetUtilization ?? 0).clamp(0.0, 100.0);
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);
    final colors = context.colors;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Animate the circular progress from 0 to final value
        final animatedUtilization = utilization * animation.value;

        // Fade in and scale up effect
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * animation.value),
            child: SizedBox(
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
                          value: animatedUtilization / 100,
                          strokeWidth: 8,
                          backgroundColor: colors.skeleton,
                          color: _getBudgetStatusColor(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${animatedUtilization.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.categoryName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
            ),
          ),
        );
      },
    );
  }
}

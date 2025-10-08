import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/category_breakdown.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';

/// Displays category spending as horizontal bars with percentages.
///
/// Each category shows how much was spent and what percentage of total.
/// Bars animate in with a stagger effect for a nice visual touch.
/// Tappable if you pass an onCategoryTap callback.
class CategoryBreakdownWidget extends StatefulWidget {
  final List<CategoryBreakdown> categories;
  final Function(String)? onCategoryTap;

  const CategoryBreakdownWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  State<CategoryBreakdownWidget> createState() =>
      _CategoryBreakdownWidgetState();
}

class _CategoryBreakdownWidgetState extends State<CategoryBreakdownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Start the animation when widget appears
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '৳');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.categories.length, (index) {
              final category = widget.categories[index];
              // Each bar animates in a bit after the previous one for a wave effect
              final delay = index * 0.1; // 100ms between each
              final animation = CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay.clamp(0.0, 0.6), // When to start
                  (delay + 0.4).clamp(
                    0.4,
                    1.0,
                  ), // When to finish (400ms per bar)
                  curve: Curves.easeOut,
                ),
              );

              return _CategoryBar(
                category: category,
                currencyFormat: currencyFormat,
                animation: animation,
                onTap: widget.onCategoryTap != null
                    ? () => widget.onCategoryTap!(category.categoryId)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final CategoryBreakdown category;
  final NumberFormat currencyFormat;
  final Animation<double> animation;
  final VoidCallback? onTap;

  const _CategoryBar({
    required this.category,
    required this.currencyFormat,
    required this.animation,
    this.onTap,
  });

  Color _parseColor(String colorString) {
    final hexColor = colorString.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _parseColor(
                              category.categoryColor,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconData(category.categoryIcon),
                            size: 20,
                            color: _parseColor(category.categoryColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.categoryName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${category.transactionCount} transactions',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(category.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${category.percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        // Animate bar from 0 to final percentage
                        value: (category.percentage / 100) * animation.value,
                        backgroundColor: context.colors.skeleton,
                        color: _parseColor(category.categoryColor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'school':
        return Icons.school;
      case 'face':
        return Icons.face;
      default:
        return Icons.category;
    }
  }
}

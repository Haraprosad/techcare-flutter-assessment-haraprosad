import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/category.dart';

/// Horizontal scrollable category chip list
class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category) onCategorySelected;
  final bool enabled;
  final String? errorText;

  const CategorySelector({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
    this.enabled = true,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Row(
            children: [
              Text(
                'Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasError
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '*',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),

        // Category chips
        if (categories.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                'No categories available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 110.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory?.id == category.id;

                return _CategoryChip(
                  category: category,
                  isSelected: isSelected,
                  onTap: enabled ? () => onCategorySelected(category) : null,
                );
              },
            ),
          ),

        // Error message
        if (hasError) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16.sp,
                  color: theme.colorScheme.error,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  Color _parseColor(String colorString) {
    try {
      // Remove '#' if present
      final cleanColor = colorString.replaceAll('#', '');
      // Add FF for full opacity and parse
      return Color(int.parse('FF$cleanColor', radix: 16));
    } catch (e) {
      // Default color if parsing fails
      return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _parseColor(category.color);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 85.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? categoryColor.withOpacity(0.15)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? categoryColor : Colors.transparent,
                width: 2.w,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    color: categoryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 6.h),

                // Category name
                Text(
                  category.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? categoryColor
                        : theme.colorScheme.onSurface,
                    fontSize: 11.sp,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Map common icon names to IconData
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,
      'fitness_center': Icons.fitness_center,
      'school': Icons.school,
      'face': Icons.face,
      'payments': Icons.payments,
      'work': Icons.work,
      'card_giftcard': Icons.card_giftcard,
    };

    return iconMap[iconName] ?? Icons.category;
  }
}

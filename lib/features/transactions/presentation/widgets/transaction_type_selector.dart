import 'package:flutter/material.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';

/// Animated toggle switch for income/expense selection
class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;
  final bool enabled;

  const TransactionTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TypeOption(
              label: 'Expense',
              icon: Icons.arrow_upward,
              isSelected: selectedType == TransactionType.expense,
              color: colors.expense,
              onTap: enabled
                  ? () => onTypeChanged(TransactionType.expense)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TypeOption(
              label: 'Income',
              icon: Icons.arrow_downward,
              isSelected: selectedType == TransactionType.income,
              color: colors.income,
              onTap: enabled
                  ? () => onTypeChanged(TransactionType.income)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  const _TypeOption({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

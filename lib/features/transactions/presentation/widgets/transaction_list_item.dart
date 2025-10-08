import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/pages/add_edit_transaction_screen.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';

/// Individual transaction list item with swipe actions and animations
class TransactionListItem extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onDelete;
  final int index; // For stagger animation
  final bool animate; // Whether to animate on build

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onRefresh,
    this.onDelete,
    this.index = 0,
    this.animate = true,
  });

  @override
  State<TransactionListItem> createState() => _TransactionListItemState();
}

class _TransactionListItemState extends State<TransactionListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation with stagger delay
    if (widget.animate) {
      Future.delayed(Duration(milliseconds: widget.index * 50), () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.isIncome;
    final colors = context.colors;
    final amountColor = isIncome ? colors.income : colors.expense;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dismissible(
          key: Key(widget.transaction.id),
          background: _buildSwipeBackground(
            color: colors.primary,
            icon: Icons.edit,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
          ),
          secondaryBackground: _buildSwipeBackground(
            color: colors.expense,
            icon: Icons.delete,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Delete action
              final confirmed = await _showDeleteConfirmation(context);
              return confirmed == true;
            } else {
              // Edit action - open edit screen
              await _handleEdit(context);
              return false;
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              // Call delete after dismissal animation completes
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            }
          },
          // Smooth swipe animation settings
          movementDuration: const Duration(milliseconds: 200),
          resizeDuration: const Duration(milliseconds: 300),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 1,
            child: ListTile(
              onTap: widget.onTap,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Hero(
                tag: 'transaction_icon_${widget.transaction.id}',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(
                    int.parse(
                      widget.transaction.category.color.replaceFirst(
                        '#',
                        '0xFF',
                      ),
                    ),
                  ).withOpacity(0.15),
                  child: Icon(
                    _getIconData(widget.transaction.category.icon),
                    color: Color(
                      int.parse(
                        widget.transaction.category.color.replaceFirst(
                          '#',
                          '0xFF',
                        ),
                      ),
                    ),
                    size: 24,
                  ),
                ),
              ),
              title: Text(
                widget.transaction.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    widget.transaction.category.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (widget.transaction.description != null &&
                      widget.transaction.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.transaction.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'transaction_amount_${widget.transaction.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        '${isIncome ? '+' : '-'} BDT ${NumberFormat('#,##0.00').format(widget.transaction.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: amountColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(widget.transaction.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    required EdgeInsets padding,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: padding,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    // Open the edit screen as a modal bottom sheet
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AddEditTransactionScreen(transaction: widget.transaction),
        ),
      ),
    );

    // If transaction was updated, refresh the list
    if (result == true && widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
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
      case 'payments':
        return Icons.payments;
      case 'work':
        return Icons.work;
      default:
        return Icons.category;
    }
  }
}

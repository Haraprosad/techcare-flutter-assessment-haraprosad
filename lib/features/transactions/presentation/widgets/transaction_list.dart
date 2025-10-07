import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_details_modal.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_list_item.dart';

/// Transaction list with grouped date headers, infinite scroll, and animations
class TransactionList extends StatefulWidget {
  final ScrollController scrollController;
  final List<Transaction> transactions;
  final bool isLoadingMore;
  final VoidCallback? onRefresh;

  const TransactionList({
    super.key,
    required this.scrollController,
    required this.transactions,
    required this.isLoadingMore,
    this.onRefresh,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  int _currentAnimationIndex = 0;
  bool _initialAnimationComplete = false;

  @override
  void initState() {
    super.initState();
    // Mark animation as complete after initial load
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _initialAnimationComplete = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset animation index if transactions list changed significantly
    if (widget.transactions.length != oldWidget.transactions.length) {
      _currentAnimationIndex = 0;
    }
  }

  Map<String, List<Transaction>> _groupTransactionsByDate() {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in widget.transactions) {
      final dateKey = transaction.dateKey;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _groupTransactionsByDate();
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

    return ListView.builder(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sortedDates.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == sortedDates.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final dateKey = sortedDates[index];
        final dateTransactions = groupedTransactions[dateKey]!;
        final isFirstGroup = index == 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header with fade animation
            _AnimatedDateHeader(
              dateKey: dateKey,
              isFirstGroup: isFirstGroup,
              dateText: _formatDateHeader(dateKey),
              animate: !_initialAnimationComplete,
              groupIndex: index,
            ),

            // Transaction Items with stagger animation
            ...dateTransactions.asMap().entries.map((entry) {
              final itemIndex = _currentAnimationIndex++;
              return TransactionListItem(
                transaction: entry.value,
                onTap: () => _onTransactionTap(context, entry.value),
                onRefresh: widget.onRefresh,
                onDelete: () => _onTransactionDelete(context, entry.value),
                index: itemIndex,
                animate: !_initialAnimationComplete,
              );
            }),
          ],
        );
      },
    );
  }

  void _onTransactionTap(BuildContext context, Transaction transaction) async {
    final result = await TransactionDetailsModal.show(
      context: context,
      transaction: transaction,
    );

    // Refresh the list if transaction was updated or deleted
    if (result == true && widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  void _onTransactionDelete(BuildContext context, Transaction transaction) {
    // Dispatch delete event to bloc
    context.read<TransactionBloc>().add(DeleteTransactionEvent(transaction.id));
  }
}

/// Animated date header widget
class _AnimatedDateHeader extends StatefulWidget {
  final String dateKey;
  final bool isFirstGroup;
  final String dateText;
  final bool animate;
  final int groupIndex;

  const _AnimatedDateHeader({
    required this.dateKey,
    required this.isFirstGroup,
    required this.dateText,
    required this.animate,
    required this.groupIndex,
  });

  @override
  State<_AnimatedDateHeader> createState() => _AnimatedDateHeaderState();
}

class _AnimatedDateHeaderState extends State<_AnimatedDateHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation with slight delay based on group index
    if (widget.animate) {
      Future.delayed(Duration(milliseconds: widget.groupIndex * 30), () {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: widget.isFirstGroup ? 0 : 16,
            bottom: 8,
          ),
          child: Text(
            widget.dateText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

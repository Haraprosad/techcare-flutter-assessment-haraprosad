import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_list_item.dart';

/// Transaction list with grouped date headers and infinite scroll
class TransactionList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Transaction> transactions;
  final bool isLoadingMore;

  const TransactionList({
    super.key,
    required this.scrollController,
    required this.transactions,
    required this.isLoadingMore,
  });

  Map<String, List<Transaction>> _groupTransactionsByDate() {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
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
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sortedDates.length + (isLoadingMore ? 1 : 0),
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
            // Date Header (Sticky)
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: isFirstGroup ? 0 : 16,
                bottom: 8,
              ),
              child: Text(
                _formatDateHeader(dateKey),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // Transaction Items
            ...dateTransactions.map(
              (transaction) => TransactionListItem(
                transaction: transaction,
                onTap: () => _onTransactionTap(context, transaction),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onTransactionTap(BuildContext context, Transaction transaction) {
    // TODO: Navigate to transaction details
  }
}

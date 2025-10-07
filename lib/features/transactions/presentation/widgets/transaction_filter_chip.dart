import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/bloc/transaction_bloc.dart';

/// Filter chip displaying active filter count
class TransactionFilterChip extends StatelessWidget {
  final VoidCallback onFilterPressed;

  const TransactionFilterChip({super.key, required this.onFilterPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final filterCount = state.activeFilterCount;

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_list, size: 18),
              const SizedBox(width: 4),
              Text('Filters${filterCount > 0 ? ' ($filterCount)' : ''}'),
            ],
          ),
          selected: filterCount > 0,
          onSelected: (_) => onFilterPressed(),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
        );
      },
    );
  }
}

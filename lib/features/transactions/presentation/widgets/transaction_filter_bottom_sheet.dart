import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/bloc/transaction_bloc.dart';

/// Filter bottom sheet for transaction filtering
/// Includes: Date range, Transaction type, Amount range, and Category filters
class TransactionFilterBottomSheet extends StatefulWidget {
  const TransactionFilterBottomSheet({super.key});

  @override
  State<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends State<TransactionFilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _selectedType;
  double _minAmount = 0;
  double _maxAmount = 100000;
  List<String> _selectedCategories = [];
  DateTime? _lastRangeSliderUpdate;

  @override
  void initState() {
    super.initState();
    final currentFilters = context.read<TransactionBloc>().state.filters;
    _startDate = currentFilters.startDate;
    _endDate = currentFilters.endDate;
    _selectedType = currentFilters.type;
    _minAmount = currentFilters.minAmount ?? 0;
    _maxAmount = currentFilters.maxAmount ?? 100000;
    _selectedCategories = List.from(currentFilters.categoryIds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Transactions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Date Range Section
          Text(
            'Date Range',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: _startDate != null
                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                      : 'Start Date',
                  onTap: () => _selectStartDate(context),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward),
              const SizedBox(width: 8),
              Expanded(
                child: _DateButton(
                  label: _endDate != null
                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                      : 'End Date',
                  onTap: () => _selectEndDate(context),
                ),
              ),
            ],
          ),

          // Quick Date Presets
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _PresetChip(label: 'Today', onTap: () => _setDatePreset(0)),
              _PresetChip(label: 'This Week', onTap: () => _setDatePreset(7)),
              _PresetChip(label: 'This Month', onTap: () => _setDatePreset(30)),
              _PresetChip(
                label: 'Last 3 Months',
                onTap: () => _setDatePreset(90),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Transaction Type
          Text(
            'Transaction Type',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<TransactionType?>(
            segments: const [
              ButtonSegment(
                value: null,
                label: Text('All'),
                icon: Icon(Icons.all_inclusive),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text('Income'),
                icon: Icon(Icons.arrow_upward),
              ),
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('Expense'),
                icon: Icon(Icons.arrow_downward),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (Set<TransactionType?> selected) {
              setState(() {
                _selectedType = selected.first;
              });
            },
          ),

          const SizedBox(height: 24),

          // Amount Range
          Text(
            'Amount Range',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(_minAmount, _maxAmount),
            min: 0,
            max: 100000,
            divisions: 100,
            labels: RangeLabels(
              'BDT ${_minAmount.toInt()}',
              'BDT ${_maxAmount.toInt()}',
            ),
            onChanged: (RangeValues values) {
              // Throttle setState to 50ms while dragging for better performance
              final now = DateTime.now();
              if (_lastRangeSliderUpdate != null &&
                  now.difference(_lastRangeSliderUpdate!).inMilliseconds < 50) {
                // Update values without setState to avoid excessive rebuilds
                _minAmount = values.start;
                _maxAmount = values.end;
                return;
              }

              _lastRangeSliderUpdate = now;
              setState(() {
                _minAmount = values.start;
                _maxAmount = values.end;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BDT ${_minAmount.toInt()}'),
              Text('BDT ${_maxAmount.toInt()}'),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _setDatePreset(int days) {
    setState(() {
      _endDate = DateTime.now();
      _startDate = _endDate!.subtract(Duration(days: days));
    });
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = null;
      _minAmount = 0;
      _maxAmount = 100000;
      _selectedCategories = [];
    });
  }

  void _applyFilters() {
    final filters = TransactionFilters(
      startDate: _startDate,
      endDate: _endDate,
      type: _selectedType,
      minAmount: _minAmount > 0 ? _minAmount : null,
      maxAmount: _maxAmount < 100000 ? _maxAmount : null,
      categoryIds: _selectedCategories,
    );

    context.read<TransactionBloc>().add(ApplyFiltersEvent(filters));
    Navigator.pop(context);
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(label),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

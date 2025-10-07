import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/core/di/injection.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/pages/add_edit_transaction_screen.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_search_bar.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_filter_chip.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_list.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_empty_state.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/widgets/transaction_filter_bottom_sheet.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TransactionBloc>(),
      child: const _TransactionsScreenBody(),
    );
  }
}

class _TransactionsScreenBody extends StatefulWidget {
  const _TransactionsScreenBody();

  @override
  State<_TransactionsScreenBody> createState() =>
      _TransactionsScreenBodyState();
}

class _TransactionsScreenBodyState extends State<_TransactionsScreenBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Add the initial load event here instead of in BlocProvider.create
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionBloc>().add(
          const LoadTransactionsEvent(page: 1),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionBloc>().add(const LoadMoreTransactionsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    context.read<TransactionBloc>().add(const RefreshTransactionsEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions'), elevation: 0),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TransactionSearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                TransactionFilterChip(
                  onFilterPressed: () => _showFilterBottomSheet(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state.isLoading && !state.hasTransactions) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!state.hasTransactions) {
                  return TransactionEmptyState(
                    hasActiveFilters: state.hasActiveFilters,
                    onClearFilters: () {
                      context.read<TransactionBloc>().add(
                        const ClearFiltersEvent(),
                      );
                    },
                  );
                }
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: TransactionList(
                    scrollController: _scrollController,
                    transactions: state.transactions,
                    isLoadingMore: state.isLoadingMore,
                    onRefresh: () {
                      context.read<TransactionBloc>().add(
                        const RefreshTransactionsEvent(),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTransaction(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final bloc = context.read<TransactionBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const TransactionFilterBottomSheet(),
      ),
    );
  }

  void _navigateToAddTransaction(BuildContext context) async {
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
          child: const AddEditTransactionScreen(),
        ),
      ),
    );

    // Refresh the list if transaction was saved
    if (result == true && mounted) {
      context.read<TransactionBloc>().add(const RefreshTransactionsEvent());
    }
  }
}

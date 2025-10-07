import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:techcare_assessment_app/core/di/injection.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/recent_transactions_list.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/spending_overview.dart';

/// Dashboard Screen - Main home screen
///
/// Features:
/// - Real-time balance summary with visibility toggle
/// - Category-wise spending visualization
/// - Recent transactions with pull-to-refresh
/// - Expandable FAB for quick actions
/// - Parallax scrolling effect
/// - Skeleton loading states
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<DashboardBloc>()..add(const LoadDashboardDataEvent()),
      child: const _DashboardScreenView(),
    );
  }
}

class _DashboardScreenView extends StatefulWidget {
  const _DashboardScreenView();

  @override
  State<_DashboardScreenView> createState() => _DashboardScreenViewState();
}

class _DashboardScreenViewState extends State<_DashboardScreenView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listenWhen: (previous, current) {
          // Only listen when error state changes to prevent multiple snackbars
          return previous.failure != current.failure &&
              current.hasError &&
              !current.hasData;
        },
        listener: (context, state) {
          // Show error snackbar if there's an error and no cached data
          if (state.hasError && !state.hasData) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.failure?.translatedMessage ?? 'An error occurred',
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    context.read<DashboardBloc>().add(
                      const LoadDashboardDataEvent(),
                    );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          // Show loading state on initial load
          if (state.isLoading && !state.hasData) {
            return _buildLoadingState();
          }

          // Show empty state if no data
          if (state.isEmpty) {
            return _buildEmptyState(context);
          }

          // Show main content
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                const RefreshDashboardDataEvent(),
              );
              // Wait for refresh to complete
              await context.read<DashboardBloc>().stream.firstWhere(
                (state) => !state.isRefreshing,
              );
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(context, state),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Balance Card with visibility toggle
                        const BalanceCard(),
                        const SizedBox(height: 24),

                        // Spending Overview with category filtering
                        const SpendingOverview(),
                        const SizedBox(height: 24),

                        // Recent Transactions Header
                        _buildRecentTransactionsHeader(context),
                      ],
                    ),
                  ),
                ),

                // Recent Transactions List
                const RecentTransactionsList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildSpeedDial(context),
    );
  }

  /// Parallax app bar with notification badge
  Widget _buildAppBar(BuildContext context, DashboardState state) {
    final parallaxOffset = _scrollOffset * 0.5;

    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Transform.translate(
          offset: Offset(0, parallaxOffset),
          child: const Text(
            'TechCare Finance',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Notification badge
        badges.Badge(
          position: badges.BadgePosition.topEnd(top: 8, end: 8),
          badgeContent: Text(
            '${state.notificationCount}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          showBadge: state.notificationCount > 0,
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications screen
            },
          ),
        ),
        const SizedBox(width: 8),

        // User profile avatar
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to profile screen
            },
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Recent Transactions section header
  Widget _buildRecentTransactionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to all transactions screen
          },
          child: const Text('View All'),
        ),
      ],
    );
  }

  /// Expandable FAB for quick actions (Add Income/Expense)
  Widget _buildSpeedDial(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.grey[700],
      activeForegroundColor: Colors.white,
      visible: true,
      closeManually: false,
      curve: Curves.easeInOut,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      elevation: 8.0,
      shape: const CircleBorder(),
      heroTag: 'dashboard_fab',
      children: [
        SpeedDialChild(
          child: const Icon(Icons.arrow_upward),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Add Income',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          onTap: () {
            // TODO: Navigate to add income screen with Hero animation
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.arrow_downward),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: 'Add Expense',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          onTap: () {
            // TODO: Navigate to add expense screen with Hero animation
          },
        ),
      ],
    );
  }

  /// Skeleton loading state
  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('TechCare Finance'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[300]!, Colors.grey[100]!],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSkeletonCard(height: 180),
                const SizedBox(height: 24),
                _buildSkeletonCard(height: 200),
                const SizedBox(height: 24),
                _buildSkeletonCard(height: 300),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Skeleton card placeholder
  Widget _buildSkeletonCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
        ),
      ),
    );
  }

  /// Empty state when no data available
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No dashboard data available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DashboardBloc>().add(const LoadDashboardDataEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

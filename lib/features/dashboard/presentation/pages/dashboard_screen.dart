import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/recent_transactions_list.dart';
import 'package:techcare_assessment_app/features/dashboard/presentation/widgets/spending_overview.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/presentation/pages/add_edit_transaction_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techcare_assessment_app/core/theme/constants/breakpoints.dart';
import 'package:techcare_assessment_app/core/widgets/responsive_layout_builder.dart';
import 'package:techcare_assessment_app/core/widgets/offline_indicator_banner.dart';
import 'package:techcare_assessment_app/core/widgets/app_drawer.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';
import 'package:techcare_assessment_app/core/localization/extension/loc.dart';

/// The main dashboard - your financial overview at a glance.
///
/// Shows:
/// - Balance summary with hide/show toggle
/// - Category spending breakdown
/// - Recent transactions list
/// - Quick add transaction FAB
/// - Pull to refresh
/// - Smooth parallax scrolling effect
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load data only if it's stale - smart caching in action
    context.read<DashboardBloc>().add(const LoadDashboardDataIfNeededEvent());
    return const _DashboardScreenView();
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
  DateTime? _lastScrollUpdate;

  @override
  void initState() {
    super.initState();
    // Track scroll for parallax effect
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Throttled scroll listener for parallax effect performance
  void _onScroll() {
    final now = DateTime.now();
    // Throttle to 16ms (~60fps) for smooth parallax without excessive redraws
    if (_lastScrollUpdate != null &&
        now.difference(_lastScrollUpdate!).inMilliseconds < 16) {
      return;
    }

    _lastScrollUpdate = now;
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WithOfflineIndicator(
      child: Scaffold(
        drawer: const AppDrawer(),
        body: BlocConsumer<DashboardBloc, DashboardState>(
          listenWhen: (previous, current) {
            // Only react to error changes to avoid duplicate snackbars
            return previous.failure != current.failure &&
                current.hasError &&
                !current.hasData;
          },
          listener: (context, state) {
            // Show error message if API failed and we have no cached data
            if (state.hasError && !state.hasData) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.failure?.translatedMessage ?? 'An error occurred',
                  ),
                  action: SnackBarAction(
                    label: context.loc.retry,
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
            return ResponsiveLayoutBuilder(
              mobile: _buildMobileLayout(context, state),
              tablet: _buildTabletLayout(context, state),
            );
          },
        ),
        floatingActionButton: _buildSpeedDial(context),
      ),
    );
  }

  /// Mobile layout (portrait)
  Widget _buildMobileLayout(BuildContext context, DashboardState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboardDataEvent());
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
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Balance Card with visibility toggle
                  const BalanceCard(),
                  SizedBox(height: 24.h),

                  // Spending Overview with category filtering
                  const SpendingOverview(),
                  SizedBox(height: 24.h),

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
  }

  /// Tablet layout (grid layout for better space utilization)
  Widget _buildTabletLayout(BuildContext context, DashboardState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboardDataEvent());
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
              padding: EdgeInsets.all(context.responsiveHPadding),
              child: context.isLandscape
                  ? _buildTabletLandscapeLayout(context)
                  : _buildTabletPortraitLayout(context),
            ),
          ),

          // Recent Transactions Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveHPadding,
                vertical: 16.h,
              ),
              child: _buildRecentTransactionsHeader(context),
            ),
          ),

          // Recent Transactions List
          const RecentTransactionsList(),
        ],
      ),
    );
  }

  /// Tablet portrait: 2-column grid
  Widget _buildTabletPortraitLayout(BuildContext context) {
    return Column(
      children: [
        // Balance Card (full width)
        const BalanceCard(),
        SizedBox(height: 24.h),

        // Spending Overview (full width)
        const SpendingOverview(),
      ],
    );
  }

  /// Tablet landscape: side-by-side layout
  Widget _buildTabletLandscapeLayout(BuildContext context) {
    return Column(
      children: [
        // Balance Card (full width at top)
        const BalanceCard(),
        SizedBox(height: 24.h),

        // Spending Overview
        const SpendingOverview(),
      ],
    );
  }

  /// Parallax app bar with notification badge
  Widget _buildAppBar(BuildContext context, DashboardState state) {
    final parallaxOffset = _scrollOffset * 0.5;
    // Calculate if app bar is collapsed (collapsed when scroll > expandedHeight - toolbar height)
    final isCollapsed = _scrollOffset > (120.h - kToolbarHeight);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;

    return SliverAppBar(
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Open menu',
        ),
      ),
      title: AnimatedOpacity(
        opacity: isCollapsed ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(context.loc.app_title),
      ),
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 56.w, bottom: 16.h),
        title: AnimatedOpacity(
          opacity: isCollapsed ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Transform.translate(
            offset: Offset(0, parallaxOffset),
            child: Text(
              context.loc.app_title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      colors.success.withOpacity(0.6),
                      colors.success.withOpacity(0.1),
                    ]
                  : [
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
          position: badges.BadgePosition.topEnd(top: 8.h, end: 8.w),
          badgeContent: Text(
            '${state.notificationCount}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 10.sp,
            ),
          ),
          showBadge: state.notificationCount > 0,
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications screen
            },
          ),
        ),
        SizedBox(width: 8.w),

        // User profile avatar
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to profile screen
            },
            child: CircleAvatar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).primaryColor,
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
        Text(
          context.loc.recent_transactions,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to all transactions screen
          },
          child: Text(context.loc.view_all),
        ),
      ],
    );
  }

  /// Expandable FAB for quick actions (Add Income/Expense)
  Widget _buildSpeedDial(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final isDark = theme.brightness == Brightness.dark;

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: isDark ? colors.success : theme.primaryColor,
      foregroundColor: theme.colorScheme.onPrimary,
      activeBackgroundColor: theme.colorScheme.surfaceContainerHighest,
      activeForegroundColor: theme.colorScheme.onSurface,
      visible: true,
      closeManually: false,
      curve: Curves.easeInOut,
      overlayColor: theme.colorScheme.scrim,
      overlayOpacity: 0.5,
      elevation: 8.0,
      shape: const CircleBorder(),
      heroTag: 'dashboard_fab',
      children: [
        SpeedDialChild(
          child: const Icon(Icons.arrow_upward),
          backgroundColor: colors.income,
          foregroundColor: theme.colorScheme.onPrimary,
          label: context.loc.add_income,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          onTap: () =>
              _navigateToAddTransaction(context, TransactionType.income),
        ),
        SpeedDialChild(
          child: const Icon(Icons.arrow_downward),
          backgroundColor: colors.expense,
          foregroundColor: theme.colorScheme.onPrimary,
          label: context.loc.add_expense,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          onTap: () =>
              _navigateToAddTransaction(context, TransactionType.expense),
        ),
      ],
    );
  }

  /// Skeleton loading state
  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120.h,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(context.loc.app_title),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(context).colorScheme.surfaceContainer,
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildSkeletonCard(height: 180),
                SizedBox(height: 24.h),
                _buildSkeletonCard(height: 200),
                SizedBox(height: 24.h),
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
    final colors = context.colors;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.skeleton,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colors.skeletonShimmer),
        ),
      ),
    );
  }

  /// Navigate to Add/Edit Transaction screen as modal
  void _navigateToAddTransaction(
    BuildContext context,
    TransactionType? initialType,
  ) async {
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
          child: AddEditTransactionScreen(initialType: initialType),
        ),
      ),
    );

    // Refresh dashboard if transaction was saved
    if (result == true && mounted) {
      context.read<DashboardBloc>().add(const RefreshDashboardDataEvent());
    }
  }

  /// Empty state when no data available
  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80.sp,
            color: colors.disabled,
          ),
          SizedBox(height: 16.h),
          Text(
            'No dashboard data available',
            style: TextStyle(
              fontSize: 18.sp,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.textSecondary.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DashboardBloc>().add(const LoadDashboardDataEvent());
            },
            icon: const Icon(Icons.refresh),
            label: Text(context.loc.retry),
          ),
        ],
      ),
    );
  }
}

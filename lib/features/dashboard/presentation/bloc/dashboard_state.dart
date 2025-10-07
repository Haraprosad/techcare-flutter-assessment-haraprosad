part of 'dashboard_bloc.dart';

/// State for Dashboard BLoC
class DashboardState extends Equatable implements BaseBlocState {
  // Loading states
  @override
  final bool isLoading;
  final bool isRefreshing;

  // Error handling
  @override
  final ApiCallFailureModel? failure;

  // Dashboard data
  final DashboardData? dashboardData;

  // UI states
  final bool isBalanceVisible;
  final String? selectedCategoryId;

  // Filtered data
  final List<Transaction>? filteredTransactions;

  // Cache status
  final bool isFromCache;

  // Last updated timestamp
  final DateTime? lastUpdated;

  const DashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.dashboardData,
    this.isBalanceVisible = true,
    this.selectedCategoryId,
    this.filteredTransactions,
    this.isFromCache = false,
    this.lastUpdated,
  });

  @override
  DashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    ApiCallFailureModel? failure,
    DashboardData? dashboardData,
    bool? isBalanceVisible,
    String? selectedCategoryId,
    List<Transaction>? filteredTransactions,
    bool? isFromCache,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: failure ?? this.failure,
      dashboardData: dashboardData ?? this.dashboardData,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      isFromCache: isFromCache ?? this.isFromCache,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper getters
  bool get hasData => dashboardData != null;
  bool get hasError => failure != null;
  bool get isEmpty => !hasData && !isLoading;

  // Get balance summary safely
  BalanceSummary? get balanceSummary => dashboardData?.balanceSummary;

  // Get spending categories
  List<SpendingCategory> get spendingCategories =>
      dashboardData?.spendingByCategory ?? [];

  // Get transactions (filtered or all)
  List<Transaction> get transactions =>
      filteredTransactions ?? dashboardData?.recentTransactions ?? [];

  // Get notification count
  int get notificationCount => dashboardData?.unreadNotifications ?? 0;

  // Check if data needs refresh (older than 5 minutes)
  bool get needsRefresh {
    if (lastUpdated == null) return true;
    final difference = DateTime.now().difference(lastUpdated!);
    return difference.inMinutes > 5;
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    failure,
    dashboardData,
    isBalanceVisible,
    selectedCategoryId,
    filteredTransactions,
    isFromCache,
    lastUpdated,
  ];
}

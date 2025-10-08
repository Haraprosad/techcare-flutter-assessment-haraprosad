import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/budget_progress_widget.dart';
import '../widgets/category_breakdown_widget.dart';
import '../widgets/spending_trend_chart.dart';
import '../widgets/summary_stats_card.dart';
import '../widgets/time_period_selector.dart';
import '../../../../core/widgets/offline_indicator_banner.dart';
import 'package:techcare_assessment_app/core/theme/extensions/theme_extensions.dart';
import 'package:techcare_assessment_app/core/localization/extension/loc.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger data load only if needed (data is stale or empty)
    context.read<AnalyticsBloc>().add(const LoadAnalyticsIfNeeded());
    return const _AnalyticsView();
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return WithOfflineIndicator(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.analytics),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AnalyticsBloc>().add(const RefreshAnalytics());
              },
            ),
          ],
        ),
        body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state.isLoading && !state.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError && !state.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.failure?.translatedMessage ??
                          'Failed to load analytics',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AnalyticsBloc>().add(
                          const LoadAnalytics(),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(context.loc.retry),
                    ),
                  ],
                ),
              );
            }

            if (!state.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No analytics data available',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            final data = state.data!;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AnalyticsBloc>().add(const RefreshAnalytics());
              },
              child: ListView(
                children: [
                  // Time Period Selector
                  TimePeriodSelector(
                    selectedPeriod: state.selectedPeriod,
                    onPeriodChanged: (period) {
                      context.read<AnalyticsBloc>().add(UpdatePeriod(period));
                    },
                  ),

                  // Summary Statistics
                  SummaryStatsCard(summary: data.summary),

                  // Spending Trend Chart
                  SpendingTrendChart(trends: data.monthlyTrend),

                  // Category Breakdown
                  CategoryBreakdownWidget(
                    categories: data.categoryBreakdown,
                    onCategoryTap: (categoryId) {
                      context.read<AnalyticsBloc>().add(
                        FilterByCategory(categoryId),
                      );
                    },
                  ),

                  // Budget Progress
                  BudgetProgressWidget(categories: data.categoryBreakdown),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

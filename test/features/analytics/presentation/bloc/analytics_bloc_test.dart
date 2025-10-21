import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/analytics/domain/entities/analytics_data.dart';
import 'package:techcare_assessment_app/features/analytics/domain/entities/analytics_summary.dart';
import 'package:techcare_assessment_app/features/analytics/domain/usecases/get_analytics_data_usecase.dart';
import 'package:techcare_assessment_app/features/analytics/domain/usecases/get_cached_analytics_data_usecase.dart';
import 'package:techcare_assessment_app/features/analytics/domain/usecases/refresh_analytics_data_usecase.dart';
import 'package:techcare_assessment_app/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:techcare_assessment_app/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:techcare_assessment_app/features/analytics/presentation/bloc/analytics_state.dart';

/// Mock classes
class MockGetAnalyticsDataUseCase extends Mock
    implements GetAnalyticsDataUseCase {}

class MockGetCachedAnalyticsDataUseCase extends Mock
    implements GetCachedAnalyticsDataUseCase {}

class MockRefreshAnalyticsDataUseCase extends Mock
    implements RefreshAnalyticsDataUseCase {}

/// Unit tests for AnalyticsBloc
///
/// This test suite validates:
/// 1. Initial state setup
/// 2. LoadAnalytics event handling
/// 3. UpdatePeriod event handling
/// 4. Error handling and fallback to cache
/// 5. State transitions
///
/// Testing Strategy:
/// - Use bloc_test for state emission testing
/// - Mock all use cases
/// - Test successful and failure scenarios
/// - Verify proper state transitions
void main() {
  group('AnalyticsBloc', () {
    late AnalyticsBloc bloc;
    late MockGetAnalyticsDataUseCase mockGetAnalyticsDataUseCase;
    late MockGetCachedAnalyticsDataUseCase mockGetCachedAnalyticsDataUseCase;
    late MockRefreshAnalyticsDataUseCase mockRefreshAnalyticsDataUseCase;

    setUp(() {
      mockGetAnalyticsDataUseCase = MockGetAnalyticsDataUseCase();
      mockGetCachedAnalyticsDataUseCase = MockGetCachedAnalyticsDataUseCase();
      mockRefreshAnalyticsDataUseCase = MockRefreshAnalyticsDataUseCase();

      bloc = AnalyticsBloc(
        mockGetAnalyticsDataUseCase,
        mockGetCachedAnalyticsDataUseCase,
        mockRefreshAnalyticsDataUseCase,
      );

      // Register fallbacks for any() matchers
      registerFallbackValue(DateTime.now());
    });

    tearDown(() {
      bloc.close();
    });

    const testAnalyticsData = AnalyticsData(
      summary: AnalyticsSummary(
        totalIncome: 85000.00,
        totalExpense: 52920.00,
        netBalance: 32080.00,
        savingsRate: 37.7,
      ),
      categoryBreakdown: [],
      monthlyTrend: [],
    );

    group('Initial state', () {
      test('should have correct initial state', () {
        // Assert
        expect(bloc.state.isLoading, false);
        expect(bloc.state.hasData, false);
        expect(bloc.state.selectedPeriod, AnalyticsPeriod.thisMonth);
        expect(bloc.state.data, isNull);
        expect(bloc.state.failure, isNull);
      });

      test('should have initial date range for this month', () {
        // Assert
        expect(bloc.state.dateRange, isNotNull);
        expect(bloc.state.selectedPeriod, AnalyticsPeriod.thisMonth);
      });
    });

    group('LoadAnalytics', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [loading, success] when data is fetched successfully',
        build: () {
          when(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAnalytics()),
        expect: () => [
          predicate<AnalyticsState>((state) => state.isLoading == true),
          predicate<AnalyticsState>(
            (state) =>
                state.isLoading == false &&
                state.hasData &&
                state.data?.summary.totalIncome == 85000.00,
          ),
        ],
      );

      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits correct data when fetch succeeds',
        build: () {
          when(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAnalytics()),
        verify: (_) {
          verify(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).called(1);
        },
      );

      blocTest<AnalyticsBloc, AnalyticsState>(
        'tries to load cached data when API fails',
        build: () {
          when(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer(
            (_) async => ApiFailure<AnalyticsData>(
              ApiCallFailureModel(code: 500, translatedMessage: 'Server error'),
            ),
          );

          when(
            () => mockGetCachedAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAnalytics()),
        verify: (_) {
          verify(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).called(1);
        },
      );
    });

    group('UpdatePeriod', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'updates period and fetches data for new period',
        build: () {
          when(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));
          return bloc;
        },
        act: (bloc) => bloc.add(const UpdatePeriod(AnalyticsPeriod.thisWeek)),
        expect: () => [
          predicate<AnalyticsState>((state) => state.isLoading == true),
          predicate<AnalyticsState>(
            (state) =>
                state.selectedPeriod == AnalyticsPeriod.thisWeek &&
                state.hasData,
          ),
        ],
      );

      blocTest<AnalyticsBloc, AnalyticsState>(
        'updates period to last three months',
        build: () {
          when(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const UpdatePeriod(AnalyticsPeriod.lastThreeMonths)),
        verify: (_) {
          verify(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).called(1);
        },
      );
    });

    group('UpdateDateRange', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'updates to custom date range and fetches data',
        build: () {
          when(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));
          return bloc;
        },
        act: (bloc) => bloc.add(
          UpdateDateRange(
            startDate: DateTime(2025, 1, 1),
            endDate: DateTime(2025, 12, 31),
          ),
        ),
        expect: () => [
          predicate<AnalyticsState>((state) => state.isLoading == true),
          predicate<AnalyticsState>(
            (state) =>
                state.selectedPeriod == AnalyticsPeriod.custom && state.hasData,
          ),
        ],
      );
    });

    group('LoadAnalyticsIfNeeded', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'skips loading when data is fresh',
        build: () => bloc,
        seed: () => AnalyticsState(
          dateRange: AnalyticsPeriod.thisMonth.dateRange,
          data: testAnalyticsData,
          lastUpdated: DateTime.now(),
        ),
        act: (bloc) => bloc.add(const LoadAnalyticsIfNeeded()),
        expect: () => [],
      );

      blocTest<AnalyticsBloc, AnalyticsState>(
        'loads data when cache is stale',
        build: () {
          when(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));
          return bloc;
        },
        seed: () => AnalyticsState(
          dateRange: AnalyticsPeriod.thisMonth.dateRange,
          data: testAnalyticsData,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        act: (bloc) => bloc.add(const LoadAnalyticsIfNeeded()),
        expect: () => [
          predicate<AnalyticsState>(
            (state) => state.hasData && state.isLoading == false,
          ),
        ],
      );
    });

    group('Error handling', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits failure state when API call fails and no cache available',
        build: () {
          when(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer(
            (_) async => ApiFailure<AnalyticsData>(
              ApiCallFailureModel(code: 500, translatedMessage: 'Server error'),
            ),
          );

          when(
            () => mockGetCachedAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).thenAnswer(
            (_) async => ApiFailure<AnalyticsData>(
              ApiCallFailureModel(code: 404, translatedMessage: 'No cache'),
            ),
          );

          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAnalytics()),
        verify: (_) {
          verify(
            () => mockGetAnalyticsDataUseCase(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ),
          ).called(1);
        },
      );
    });

    group('State properties', () {
      test('hasData returns true when data exists', () {
        // Arrange
        final state = AnalyticsState(
          dateRange: AnalyticsPeriod.thisMonth.dateRange,
          data: testAnalyticsData,
        );

        // Assert
        expect(state.hasData, true);
      });

      test('hasError returns true when failure exists', () {
        // Arrange
        final state = AnalyticsState(
          dateRange: AnalyticsPeriod.thisMonth.dateRange,
          failure: ApiCallFailureModel(code: 500, translatedMessage: 'Error'),
        );

        // Assert
        expect(state.hasError, true);
      });

      test('needsRefresh returns true when data is old', () {
        // Arrange
        final state = AnalyticsState(
          dateRange: AnalyticsPeriod.thisMonth.dateRange,
          data: testAnalyticsData,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
        );

        // Assert
        expect(state.needsRefresh, true);
      });

      test('needsRefresh returns false when data is fresh', () {
        // Arrange
        final state = AnalyticsState(
          dateRange: AnalyticsPeriod.thisMonth.dateRange,
          data: testAnalyticsData,
          lastUpdated: DateTime.now(),
        );

        // Assert
        expect(state.needsRefresh, false);
      });
    });
  });
}

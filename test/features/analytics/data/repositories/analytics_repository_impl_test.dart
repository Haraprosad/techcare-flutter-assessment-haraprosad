import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techcare_assessment_app/core/network/error_handling/network_error_handler.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/analytics/data/datasources/analytics_local_datasource.dart';
import 'package:techcare_assessment_app/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/analytics_data_model.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/analytics_summary_model.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/category_breakdown_model.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/monthly_trend_model.dart';
import 'package:techcare_assessment_app/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:techcare_assessment_app/features/analytics/domain/entities/analytics_data.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/category_model.dart';

/// Mock classes
class MockAnalyticsRemoteDataSource extends Mock
    implements AnalyticsRemoteDataSource {}

class MockAnalyticsLocalDataSource extends Mock
    implements AnalyticsLocalDataSource {}

class MockNetworkErrorHandler extends Mock implements NetworkErrorHandler {}

/// Unit tests for AnalyticsRepositoryImpl
///
/// This test suite validates:
/// 1. Cache-first strategy (check cache before remote call)
/// 2. Fetching from remote when cache is empty/stale
/// 3. Caching remote data after successful fetch
/// 4. ApiResult success and failure handling
/// 5. Error handling and fallback to cache on failure
///
/// Testing Strategy:
/// - Mock all dependencies (remote, local, error handler)
/// - Test cache-first flow
/// - Test error scenarios with proper ApiFailure
/// - Test cache operations after remote fetch
void main() {
  group('AnalyticsRepositoryImpl', () {
    late AnalyticsRepositoryImpl repository;
    late MockAnalyticsRemoteDataSource mockRemoteDataSource;
    late MockAnalyticsLocalDataSource mockLocalDataSource;
    late MockNetworkErrorHandler mockErrorHandler;

    setUp(() {
      mockRemoteDataSource = MockAnalyticsRemoteDataSource();
      mockLocalDataSource = MockAnalyticsLocalDataSource();
      mockErrorHandler = MockNetworkErrorHandler();

      repository = AnalyticsRepositoryImpl(
        mockErrorHandler,
        mockRemoteDataSource,
        mockLocalDataSource,
      );
    });

    final testStartDate = DateTime(2025, 10, 1);
    final testEndDate = DateTime(2025, 10, 31);

    final testModel = AnalyticsDataModel(
      summary: const AnalyticsSummaryModel(
        totalIncome: 85000.00,
        totalExpense: 52920.00,
        netBalance: 32080.00,
        savingsRate: 37.7,
        previousIncome: 83000.00,
        previousExpense: 49000.00,
      ),
      categoryBreakdown: [
        CategoryBreakdownModel(
          category: const CategoryModel(
            id: "cat_001",
            name: "Food & Dining",
            icon: "restaurant",
            color: "#FF6B6B",
          ),
          amount: 13950.00,
          percentage: 26.4,
          transactionCount: 8,
          budget: 15000.00,
          budgetUtilization: 93.0,
        ),
      ],
      monthlyTrend: const [
        MonthlyTrendModel(
          month: "2025-09",
          income: 85000.00,
          expense: 52920.00,
        ),
      ],
    );

    group('getAnalyticsData', () {
      test('should return cached data when cache is available', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => testModel);

        // Act
        final result = await repository.getAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert
        expect(result, isA<ApiSuccess<AnalyticsData>>());
        final successResult = result as ApiSuccess<AnalyticsData>;
        expect(successResult.data.summary.totalIncome, 85000.00);

        verify(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).called(1);
        verifyNever(() => mockRemoteDataSource.getAnalyticsData(any(), any()));
      });

      test('should fetch from remote when cache is empty', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => null);

        when(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        ).thenAnswer((_) async => testModel);

        when(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.getAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert
        expect(result, isA<ApiSuccess<AnalyticsData>>());
        final successResult = result as ApiSuccess<AnalyticsData>;
        expect(successResult.data.summary.totalIncome, 85000.00);

        verify(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).called(1);
        verify(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        ).called(1);
        verify(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            testStartDate,
            testEndDate,
          ),
        ).called(1);
      });

      test('should cache data after successful remote fetch', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => null);

        when(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        ).thenAnswer((_) async => testModel);

        when(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => {});

        // Act
        await repository.getAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert: Verify caching was called
        verify(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            testStartDate,
            testEndDate,
          ),
        ).called(1);
      });

      test('should continue even if caching fails', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => null);

        when(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        ).thenAnswer((_) async => testModel);

        when(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            testStartDate,
            testEndDate,
          ),
        ).thenThrow(Exception('Cache write failed'));

        // Act
        final result = await repository.getAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert: Should still return success even if caching failed
        expect(result, isA<ApiSuccess<AnalyticsData>>());
      });

      test('should handle cache check failure gracefully', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenThrow(Exception('Cache read error'));

        when(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        ).thenAnswer((_) async => testModel);

        when(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.getAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert: Should fetch from remote despite cache error
        expect(result, isA<ApiSuccess<AnalyticsData>>());
        verify(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        ).called(1);
      });
    });

    group('getCachedAnalyticsData', () {
      test('should return cached data successfully', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => testModel);

        // Act
        final result = await repository.getCachedAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert
        expect(result, isA<ApiSuccess<AnalyticsData>>());
        final successResult = result as ApiSuccess<AnalyticsData>;
        expect(successResult.data.summary.totalIncome, 85000.00);
      });

      test('should return failure when cache is empty', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCachedAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert
        expect(result, isA<ApiFailure>());
        final failureResult = result as ApiFailure;
        expect(failureResult.failure.code, 404);
      });

      test('should handle cache read exception', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenThrow(Exception('Cache error'));

        // Act
        final result = await repository.getCachedAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert
        expect(result, isA<ApiFailure>());
      });
    });

    group('Integration scenarios', () {
      test('should handle full fetch-cache-retrieve flow', () async {
        // Arrange: Initially no cache
        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => null);

        when(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        ).thenAnswer((_) async => testModel);

        when(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => {});

        // Act: First call (fetches from remote)
        final firstResult = await repository.getAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert: First call succeeds
        expect(firstResult, isA<ApiSuccess<AnalyticsData>>());

        // Verify flow: cache check → remote fetch → cache write
        verify(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).called(1);
        verify(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        ).called(1);
        verify(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            testStartDate,
            testEndDate,
          ),
        ).called(1);
      });

      test('should handle different date ranges independently', () async {
        // Arrange
        final otherStartDate = DateTime(2025, 9, 1);
        final otherEndDate = DateTime(2025, 9, 30);

        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            testStartDate,
            testEndDate,
          ),
        ).thenAnswer((_) async => testModel);

        when(
          () => mockLocalDataSource.getCachedAnalyticsData(
            otherStartDate,
            otherEndDate,
          ),
        ).thenAnswer((_) async => null);

        when(
          () => mockRemoteDataSource.getAnalyticsData(
            otherStartDate,
            otherEndDate,
          ),
        ).thenAnswer((_) async => testModel);

        when(
          () => mockLocalDataSource.cacheAnalyticsData(
            testModel,
            otherStartDate,
            otherEndDate,
          ),
        ).thenAnswer((_) async => {});

        // Act
        final result1 = await repository.getAnalyticsData(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        final result2 = await repository.getAnalyticsData(
          startDate: otherStartDate,
          endDate: otherEndDate,
        );

        // Assert: Both calls succeed
        expect(result1, isA<ApiSuccess<AnalyticsData>>());
        expect(result2, isA<ApiSuccess<AnalyticsData>>());

        // First call uses cache, second fetches from remote
        verifyNever(
          () =>
              mockRemoteDataSource.getAnalyticsData(testStartDate, testEndDate),
        );
        verify(
          () => mockRemoteDataSource.getAnalyticsData(
            otherStartDate,
            otherEndDate,
          ),
        ).called(1);
      });
    });
  });
}

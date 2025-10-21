import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techcare_assessment_app/core/network/error_handling/models/api_call_failure_model.dart';
import 'package:techcare_assessment_app/core/network/models/api_result.dart';
import 'package:techcare_assessment_app/features/analytics/domain/entities/analytics_data.dart';
import 'package:techcare_assessment_app/features/analytics/domain/entities/analytics_summary.dart';
import 'package:techcare_assessment_app/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:techcare_assessment_app/features/analytics/domain/usecases/get_analytics_data_usecase.dart';

/// Mock class for AnalyticsRepository
class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

/// Unit tests for GetAnalyticsDataUseCase
///
/// This test suite validates:
/// 1. Use case calls repository with correct parameters
/// 2. Returns ApiSuccess when repository succeeds
/// 3. Returns ApiFailure when repository fails
/// 4. Proper date range handling
///
/// Testing Strategy:
/// - Mock repository to isolate use case
/// - Test successful data retrieval
/// - Test failure scenarios
/// - Verify repository method calls
void main() {
  group('GetAnalyticsDataUseCase', () {
    late GetAnalyticsDataUseCase useCase;
    late MockAnalyticsRepository mockRepository;

    setUp(() {
      mockRepository = MockAnalyticsRepository();
      useCase = GetAnalyticsDataUseCase(mockRepository);
    });

    final testStartDate = DateTime(2025, 10, 1);
    final testEndDate = DateTime(2025, 10, 31);

    final testAnalyticsData = const AnalyticsData(
      summary: AnalyticsSummary(
        totalIncome: 85000.00,
        totalExpense: 52920.00,
        netBalance: 32080.00,
        savingsRate: 37.7,
        previousIncome: 83000.00,
        previousExpense: 49000.00,
      ),
      categoryBreakdown: [],
      monthlyTrend: [],
    );

    group('call', () {
      test('should return ApiSuccess when repository succeeds', () async {
        // Arrange
        when(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

        // Act
        final result = await useCase(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert
        expect(result, isA<ApiSuccess<AnalyticsData>>());
        final successResult = result as ApiSuccess<AnalyticsData>;
        expect(successResult.data.summary.totalIncome, 85000.00);

        verify(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).called(1);
      });

      test('should pass correct date parameters to repository', () async {
        // Arrange
        when(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

        // Act
        await useCase(startDate: testStartDate, endDate: testEndDate);

        // Assert: Verify exact parameters
        verify(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).called(1);
      });

      test('should return ApiFailure when repository fails', () async {
        // Arrange
        final failure = ApiFailure<AnalyticsData>(
          ApiCallFailureModel(code: 500, translatedMessage: 'Server error'),
        );

        when(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).thenAnswer((_) async => failure);

        // Act
        final result = await useCase(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert
        expect(result, isA<ApiFailure>());
        final failureResult = result as ApiFailure;
        expect(failureResult.failure.code, 500);
      });

      test('should handle different date ranges', () async {
        // Arrange
        final startDate1 = DateTime(2025, 1, 1);
        final endDate1 = DateTime(2025, 1, 31);

        final startDate2 = DateTime(2025, 12, 1);
        final endDate2 = DateTime(2025, 12, 31);

        when(
          () => mockRepository.getAnalyticsData(
            startDate: startDate1,
            endDate: endDate1,
          ),
        ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

        when(
          () => mockRepository.getAnalyticsData(
            startDate: startDate2,
            endDate: endDate2,
          ),
        ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

        // Act
        final result1 = await useCase(startDate: startDate1, endDate: endDate1);

        final result2 = await useCase(startDate: startDate2, endDate: endDate2);

        // Assert
        expect(result1, isA<ApiSuccess<AnalyticsData>>());
        expect(result2, isA<ApiSuccess<AnalyticsData>>());

        verify(
          () => mockRepository.getAnalyticsData(
            startDate: startDate1,
            endDate: endDate1,
          ),
        ).called(1);

        verify(
          () => mockRepository.getAnalyticsData(
            startDate: startDate2,
            endDate: endDate2,
          ),
        ).called(1);
      });

      test('should handle current month date range', () async {
        // Arrange
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        when(
          () => mockRepository.getAnalyticsData(
            startDate: startOfMonth,
            endDate: endOfMonth,
          ),
        ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

        // Act
        final result = await useCase(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );

        // Assert
        expect(result, isA<ApiSuccess<AnalyticsData>>());
      });

      test('should handle year-long date range', () async {
        // Arrange
        final startOfYear = DateTime(2025, 1, 1);
        final endOfYear = DateTime(2025, 12, 31);

        when(
          () => mockRepository.getAnalyticsData(
            startDate: startOfYear,
            endDate: endOfYear,
          ),
        ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

        // Act
        final result = await useCase(
          startDate: startOfYear,
          endDate: endOfYear,
        );

        // Assert
        expect(result, isA<ApiSuccess<AnalyticsData>>());
        verify(
          () => mockRepository.getAnalyticsData(
            startDate: startOfYear,
            endDate: endOfYear,
          ),
        ).called(1);
      });

      test('should preserve all data from repository', () async {
        // Arrange
        const detailedData = AnalyticsData(
          summary: AnalyticsSummary(
            totalIncome: 100000.00,
            totalExpense: 60000.00,
            netBalance: 40000.00,
            savingsRate: 40.0,
            previousIncome: 95000.00,
            previousExpense: 55000.00,
          ),
          categoryBreakdown: [],
          monthlyTrend: [],
        );

        when(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).thenAnswer((_) async => ApiSuccess(detailedData));

        // Act
        final result = await useCase(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert: Verify all data is preserved
        final successResult = result as ApiSuccess<AnalyticsData>;
        expect(successResult.data.summary.totalIncome, 100000.00);
        expect(successResult.data.summary.totalExpense, 60000.00);
        expect(successResult.data.summary.netBalance, 40000.00);
        expect(successResult.data.summary.savingsRate, 40.0);
        expect(successResult.data.summary.previousIncome, 95000.00);
        expect(successResult.data.summary.previousExpense, 55000.00);
      });
    });

    group('Integration scenarios', () {
      test('should handle multiple consecutive calls', () async {
        // Arrange
        when(
          () => mockRepository.getAnalyticsData(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

        // Act: Make multiple calls
        await useCase(startDate: testStartDate, endDate: testEndDate);
        await useCase(startDate: testStartDate, endDate: testEndDate);
        await useCase(startDate: testStartDate, endDate: testEndDate);

        // Assert: All calls should succeed
        verify(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).called(3);
      });

      test('should handle success after previous failure', () async {
        // Arrange
        final failure = ApiFailure<AnalyticsData>(
          ApiCallFailureModel(code: 500, translatedMessage: 'Server error'),
        );

        when(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).thenAnswer((_) async => failure);

        // Act: First call fails
        final result1 = await useCase(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Arrange: Set up success for second call
        when(
          () => mockRepository.getAnalyticsData(
            startDate: testStartDate,
            endDate: testEndDate,
          ),
        ).thenAnswer((_) async => ApiSuccess(testAnalyticsData));

        // Act: Second call succeeds
        final result2 = await useCase(
          startDate: testStartDate,
          endDate: testEndDate,
        );

        // Assert
        expect(result1, isA<ApiFailure>());
        expect(result2, isA<ApiSuccess<AnalyticsData>>());
      });
    });
  });
}

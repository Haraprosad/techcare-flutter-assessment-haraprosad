import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techcare_assessment_app/core/network/services/mock_dashboard_service.dart';
import 'package:techcare_assessment_app/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/analytics_data_model.dart';

/// Mock class for MockDashboardService
class MockMockDashboardService extends Mock implements MockDashboardService {}

/// Unit tests for AnalyticsRemoteDataSourceImpl
///
/// This test suite validates:
/// 1. Fetching analytics data from mock service
/// 2. Date parameter handling
/// 3. JSON parsing and model creation
/// 4. Error handling when service fails
///
/// Testing Strategy:
/// - Mock MockDashboardService to isolate datasource
/// - Test successful data fetching
/// - Test JSON transformation to AnalyticsDataModel
/// - Test exception handling
void main() {
  group('AnalyticsRemoteDataSourceImpl', () {
    late AnalyticsRemoteDataSourceImpl datasource;
    late MockMockDashboardService mockService;

    setUp(() {
      mockService = MockMockDashboardService();
      datasource = AnalyticsRemoteDataSourceImpl(mockService: mockService);
    });

    final testStartDate = DateTime(2025, 10, 1);
    final testEndDate = DateTime(2025, 10, 31);

    final testAnalyticsResponse = {
      "success": true,
      "data": {
        "summary": {
          "totalIncome": 85000.00,
          "totalExpense": 52920.00,
          "netBalance": 32080.00,
          "savingsRate": 37.7,
          "previousIncome": 83000.00,
          "previousExpense": 49000.00,
        },
        "categoryBreakdown": [
          {
            "category": {
              "_id": "cat_001",
              "name": "Food & Dining",
              "icon": "restaurant",
              "color": "#FF6B6B",
            },
            "amount": 13950.00,
            "percentage": 26.4,
            "transactionCount": 8,
            "budget": 15000.00,
            "budgetUtilization": 93.0,
          },
        ],
        "monthlyTrend": [
          {"month": "2025-07", "income": 83000.00, "expense": 45000.00},
        ],
      },
    };

    group('getAnalyticsData', () {
      test('should fetch analytics data successfully', () async {
        // Arrange
        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => testAnalyticsResponse);

        // Act
        final result = await datasource.getAnalyticsData(
          testStartDate,
          testEndDate,
        );

        // Assert
        expect(result, isA<AnalyticsDataModel>());
        verify(() => mockService.getAnalyticsData()).called(1);
      });

      test('should return AnalyticsDataModel with correct data', () async {
        // Arrange
        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => testAnalyticsResponse);

        // Act
        final result = await datasource.getAnalyticsData(
          testStartDate,
          testEndDate,
        );

        // Assert
        expect(result.summary.totalIncome, 85000.00);
        expect(result.summary.totalExpense, 52920.00);
        expect(result.summary.netBalance, 32080.00);
        expect(result.categoryBreakdown.length, 1);
        expect(result.categoryBreakdown.first.amount, 13950.00);
        expect(result.monthlyTrend.length, 1);
      });

      test('should parse JSON data correctly', () async {
        // Arrange
        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => testAnalyticsResponse);

        // Act
        final result = await datasource.getAnalyticsData(
          testStartDate,
          testEndDate,
        );

        // Assert: Verify nested data is parsed correctly
        expect(result.categoryBreakdown.first.category.name, "Food & Dining");
        expect(result.categoryBreakdown.first.category.icon, "restaurant");
        expect(result.categoryBreakdown.first.category.color, "#FF6B6B");
        expect(result.monthlyTrend.first.month, "2025-07");
      });

      test('should accept different date ranges', () async {
        // Arrange
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 12, 31);

        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => testAnalyticsResponse);

        // Act
        final result = await datasource.getAnalyticsData(startDate, endDate);

        // Assert
        expect(result, isA<AnalyticsDataModel>());
        verify(() => mockService.getAnalyticsData()).called(1);
      });

      test('should handle empty category breakdown', () async {
        // Arrange
        final emptyResponse = {
          "success": true,
          "data": {
            "summary": {
              "totalIncome": 0.0,
              "totalExpense": 0.0,
              "netBalance": 0.0,
              "savingsRate": 0.0,
              "previousIncome": 0.0,
              "previousExpense": 0.0,
            },
            "categoryBreakdown": [],
            "monthlyTrend": [],
          },
        };

        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => emptyResponse);

        // Act
        final result = await datasource.getAnalyticsData(
          testStartDate,
          testEndDate,
        );

        // Assert
        expect(result.categoryBreakdown, isEmpty);
        expect(result.monthlyTrend, isEmpty);
      });

      test('should handle service exception', () async {
        // Arrange
        when(
          () => mockService.getAnalyticsData(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => datasource.getAnalyticsData(testStartDate, testEndDate),
          throwsException,
        );
      });

      test('should handle JSON parsing error', () async {
        // Arrange: Invalid JSON structure
        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => {"invalid": "structure"});

        // Act & Assert
        expect(
          () => datasource.getAnalyticsData(testStartDate, testEndDate),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle null response', () async {
        // Arrange
        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => <String, dynamic>{});

        // Act & Assert
        expect(
          () => datasource.getAnalyticsData(testStartDate, testEndDate),
          throwsA(anything),
        );
      });
    });

    group('Integration scenarios', () {
      test('should handle multiple consecutive calls', () async {
        // Arrange
        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => testAnalyticsResponse);

        // Act: Make multiple calls
        final result1 = await datasource.getAnalyticsData(
          testStartDate,
          testEndDate,
        );
        final result2 = await datasource.getAnalyticsData(
          DateTime(2025, 9, 1),
          DateTime(2025, 9, 30),
        );

        // Assert
        expect(result1, isA<AnalyticsDataModel>());
        expect(result2, isA<AnalyticsDataModel>());
        verify(() => mockService.getAnalyticsData()).called(2);
      });

      test('should work with current month date range', () async {
        // Arrange
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        when(
          () => mockService.getAnalyticsData(),
        ).thenAnswer((_) async => testAnalyticsResponse);

        // Act
        final result = await datasource.getAnalyticsData(
          startOfMonth,
          endOfMonth,
        );

        // Assert
        expect(result, isA<AnalyticsDataModel>());
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/analytics_data_model.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/analytics_summary_model.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/category_breakdown_model.dart';
import 'package:techcare_assessment_app/features/analytics/data/models/monthly_trend_model.dart';
import 'package:techcare_assessment_app/features/analytics/domain/entities/analytics_data.dart';
import 'package:techcare_assessment_app/features/dashboard/data/models/category_model.dart';

/// Unit tests for AnalyticsDataModel
///
/// This test suite validates:
/// 1. JSON deserialization (fromJson)
/// 2. Model to entity conversion (toEntity)
/// 3. Freezed equality and value comparison
/// 4. Model properties and nested objects
///
/// Testing Strategy:
/// - Test fromJson with complete and partial data
/// - Test toEntity conversion preserves data
/// - Test Freezed value equality
/// - Test nested models (summary, categoryBreakdown, monthlyTrend)
void main() {
  group('AnalyticsDataModel', () {
    final testJson = {
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
        {
          "category": {
            "_id": "cat_002",
            "name": "Transportation",
            "icon": "directions_car",
            "color": "#4ECDC4",
          },
          "amount": 6970.00,
          "percentage": 13.2,
          "transactionCount": 4,
          "budget": 10000.00,
          "budgetUtilization": 69.7,
        },
      ],
      "monthlyTrend": [
        {"month": "2025-07", "income": 83000.00, "expense": 45000.00},
        {"month": "2025-08", "income": 85000.00, "expense": 48000.00},
        {"month": "2025-09", "income": 85000.00, "expense": 52920.00},
      ],
    };

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
        CategoryBreakdownModel(
          category: const CategoryModel(
            id: "cat_002",
            name: "Transportation",
            icon: "directions_car",
            color: "#4ECDC4",
          ),
          amount: 6970.00,
          percentage: 13.2,
          transactionCount: 4,
          budget: 10000.00,
          budgetUtilization: 69.7,
        ),
      ],
      monthlyTrend: const [
        MonthlyTrendModel(
          month: "2025-07",
          income: 83000.00,
          expense: 45000.00,
        ),
        MonthlyTrendModel(
          month: "2025-08",
          income: 85000.00,
          expense: 48000.00,
        ),
        MonthlyTrendModel(
          month: "2025-09",
          income: 85000.00,
          expense: 52920.00,
        ),
      ],
    );

    group('fromJson', () {
      test('should create model from complete JSON', () {
        // Act
        final result = AnalyticsDataModel.fromJson(testJson);

        // Assert
        expect(result, isA<AnalyticsDataModel>());
        expect(result.summary.totalIncome, 85000.00);
        expect(result.summary.totalExpense, 52920.00);
        expect(result.categoryBreakdown.length, 2);
        expect(result.monthlyTrend.length, 3);
      });

      test('should parse summary correctly', () {
        // Act
        final result = AnalyticsDataModel.fromJson(testJson);

        // Assert
        expect(result.summary.totalIncome, 85000.00);
        expect(result.summary.totalExpense, 52920.00);
        expect(result.summary.netBalance, 32080.00);
        expect(result.summary.savingsRate, 37.7);
        expect(result.summary.previousIncome, 83000.00);
        expect(result.summary.previousExpense, 49000.00);
      });

      test('should parse category breakdown correctly', () {
        // Act
        final result = AnalyticsDataModel.fromJson(testJson);

        // Assert
        final firstCategory = result.categoryBreakdown.first;
        expect(firstCategory.category.name, "Food & Dining");
        expect(firstCategory.category.icon, "restaurant");
        expect(firstCategory.amount, 13950.00);
        expect(firstCategory.percentage, 26.4);
        expect(firstCategory.transactionCount, 8);
        expect(firstCategory.budget, 15000.00);
        expect(firstCategory.budgetUtilization, 93.0);
      });

      test('should parse monthly trend correctly', () {
        // Act
        final result = AnalyticsDataModel.fromJson(testJson);

        // Assert
        final firstTrend = result.monthlyTrend.first;
        expect(firstTrend.month, "2025-07");
        expect(firstTrend.income, 83000.00);
        expect(firstTrend.expense, 45000.00);
      });

      test('should handle empty category breakdown', () {
        // Arrange
        final jsonWithEmptyCategories = {...testJson, "categoryBreakdown": []};

        // Act
        final result = AnalyticsDataModel.fromJson(jsonWithEmptyCategories);

        // Assert
        expect(result.categoryBreakdown, isEmpty);
      });

      test('should handle empty monthly trend', () {
        // Arrange
        final jsonWithEmptyTrend = {...testJson, "monthlyTrend": []};

        // Act
        final result = AnalyticsDataModel.fromJson(jsonWithEmptyTrend);

        // Assert
        expect(result.monthlyTrend, isEmpty);
      });

      test('should handle optional fields', () {
        // Arrange
        final jsonWithoutOptionals = {
          "summary": {
            "totalIncome": 85000.00,
            "totalExpense": 52920.00,
            "netBalance": 32080.00,
            "savingsRate": 37.7,
          },
          "categoryBreakdown": [
            {
              "category": {
                "_id": "cat_001",
                "name": "Food",
                "icon": "restaurant",
                "color": "#FF6B6B",
              },
              "amount": 13950.00,
              "percentage": 26.4,
              "transactionCount": 8,
            },
          ],
          "monthlyTrend": [
            {"month": "2025-07", "income": 83000.00, "expense": 45000.00},
          ],
        };

        // Act
        final result = AnalyticsDataModel.fromJson(jsonWithoutOptionals);

        // Assert
        expect(result.summary.previousIncome, isNull);
        expect(result.summary.previousExpense, isNull);
        expect(result.categoryBreakdown.first.budget, isNull);
        expect(result.categoryBreakdown.first.budgetUtilization, isNull);
      });
    });

    group('toEntity', () {
      test('should convert model to entity', () {
        // Act
        final entity = testModel.toEntity();

        // Assert
        expect(entity, isA<AnalyticsData>());
        expect(entity.summary.totalIncome, testModel.summary.totalIncome);
        expect(entity.summary.totalExpense, testModel.summary.totalExpense);
        expect(
          entity.categoryBreakdown.length,
          testModel.categoryBreakdown.length,
        );
        expect(entity.monthlyTrend.length, testModel.monthlyTrend.length);
      });

      test('should preserve summary data in entity', () {
        // Act
        final entity = testModel.toEntity();

        // Assert
        expect(entity.summary.totalIncome, 85000.00);
        expect(entity.summary.totalExpense, 52920.00);
        expect(entity.summary.netBalance, 32080.00);
        expect(entity.summary.savingsRate, 37.7);
      });

      test('should preserve category breakdown in entity', () {
        // Act
        final entity = testModel.toEntity();

        // Assert
        final firstBreakdown = entity.categoryBreakdown.first;
        expect(firstBreakdown.categoryName, "Food & Dining");
        expect(firstBreakdown.amount, 13950.00);
        expect(firstBreakdown.percentage, 26.4);
        expect(firstBreakdown.transactionCount, 8);
      });

      test('should preserve monthly trend in entity', () {
        // Act
        final entity = testModel.toEntity();

        // Assert
        final firstTrend = entity.monthlyTrend.first;
        expect(firstTrend.month, "2025-07");
        expect(firstTrend.income, 83000.00);
        expect(firstTrend.expense, 45000.00);
      });
    });

    group('Freezed equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        final model1 = testModel;
        final model2 = AnalyticsDataModel(
          summary: testModel.summary,
          categoryBreakdown: testModel.categoryBreakdown,
          monthlyTrend: testModel.monthlyTrend,
        );

        // Assert
        expect(model1, equals(model2));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final model1 = testModel;
        final model2 = AnalyticsDataModel(
          summary: testModel.summary.copyWith(totalIncome: 90000.00),
          categoryBreakdown: testModel.categoryBreakdown,
          monthlyTrend: testModel.monthlyTrend,
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });

      test('should support copyWith', () {
        // Arrange
        final updatedSummary = testModel.summary.copyWith(
          totalIncome: 90000.00,
        );

        // Act
        final updatedModel = testModel.copyWith(summary: updatedSummary);

        // Assert
        expect(updatedModel.summary.totalIncome, 90000.00);
        expect(
          updatedModel.summary.totalExpense,
          testModel.summary.totalExpense,
        );
        expect(updatedModel.categoryBreakdown, testModel.categoryBreakdown);
      });
    });

    group('Integration scenarios', () {
      test('should handle complete JSON to entity flow', () {
        // Act
        final model = AnalyticsDataModel.fromJson(testJson);
        final entity = model.toEntity();

        // Assert
        expect(entity.summary.totalIncome, 85000.00);
        expect(entity.categoryBreakdown.length, 2);
        expect(entity.monthlyTrend.length, 3);
        expect(entity.categoryBreakdown.first.categoryName, "Food & Dining");
      });

      test('should handle model with empty lists', () {
        // Arrange
        final emptyModel = AnalyticsDataModel(
          summary: const AnalyticsSummaryModel(
            totalIncome: 0,
            totalExpense: 0,
            netBalance: 0,
            savingsRate: 0,
          ),
          categoryBreakdown: const [],
          monthlyTrend: const [],
        );

        // Act
        final entity = emptyModel.toEntity();

        // Assert
        expect(entity.categoryBreakdown, isEmpty);
        expect(entity.monthlyTrend, isEmpty);
      });
    });
  });
}

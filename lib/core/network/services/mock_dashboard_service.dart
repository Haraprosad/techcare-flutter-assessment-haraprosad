import 'dart:async';
import 'package:injectable/injectable.dart';

/// Mock service that simulates API responses with realistic delays
/// This eliminates the need for an external JSON server
///
/// Benefits:
/// - No external server dependency
/// - Immediate setup for reviewers/evaluators
/// - Realistic API simulation with delays
/// - Easy to switch to real API later
@singleton
class MockDashboardService {
  // Simulate realistic network delays
  static const Duration _minDelay = Duration(milliseconds: 300);
  static const Duration _maxDelay = Duration(milliseconds: 800);

  /// Simulates fetching dashboard data from API
  Future<Map<String, dynamic>> getDashboardData() async {
    await _simulateNetworkDelay();
    return _dashboardData;
  }

  /// Simulates fetching balance summary from API
  Future<Map<String, dynamic>> getBalanceSummary() async {
    await _simulateNetworkDelay();
    return _dashboardData['balanceSummary'] as Map<String, dynamic>;
  }

  /// Simulates fetching analytics data from API
  Future<Map<String, dynamic>> getAnalyticsData() async {
    await _simulateNetworkDelay();
    return _analyticsData;
  }

  /// Simulates network delay for realistic API behavior
  Future<void> _simulateNetworkDelay() async {
    final delayMs =
        _minDelay.inMilliseconds +
        ((_maxDelay.inMilliseconds - _minDelay.inMilliseconds) *
                (DateTime.now().millisecond / 1000))
            .round();
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  // Mock data - matches the structure from db.json
  static final Map<String, dynamic> _dashboardData = {
    "balanceSummary": {
      "totalBalance": 65080.00,
      "monthlyIncome": 118000.00,
      "monthlyExpense": 52920.00,
      "savingsRate": 55.2,
      "isVisible": true,
    },
    "spendingByCategory": [
      {
        "categoryId": "cat_001",
        "categoryName": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
        "amount": 13950.00,
        "percentage": 26.4,
        "transactionCount": 8,
      },
      {
        "categoryId": "cat_002",
        "categoryName": "Transportation",
        "icon": "directions_car",
        "color": "#4ECDC4",
        "amount": 6970.00,
        "percentage": 13.2,
        "transactionCount": 4,
      },
      {
        "categoryId": "cat_003",
        "categoryName": "Shopping",
        "icon": "shopping_bag",
        "color": "#FFD93D",
        "amount": 14500.00,
        "percentage": 27.4,
        "transactionCount": 3,
      },
      {
        "categoryId": "cat_004",
        "categoryName": "Entertainment",
        "icon": "movie",
        "color": "#95E1D3",
        "amount": 2800.00,
        "percentage": 5.3,
        "transactionCount": 3,
      },
      {
        "categoryId": "cat_005",
        "categoryName": "Bills & Utilities",
        "icon": "receipt",
        "color": "#F38181",
        "amount": 6000.00,
        "percentage": 11.3,
        "transactionCount": 4,
      },
      {
        "categoryId": "cat_006",
        "categoryName": "Healthcare",
        "icon": "local_hospital",
        "color": "#BA68C8",
        "amount": 850.00,
        "percentage": 1.6,
        "transactionCount": 1,
      },
      {
        "categoryId": "cat_007",
        "categoryName": "Fitness",
        "icon": "fitness_center",
        "color": "#FF7043",
        "amount": 3000.00,
        "percentage": 5.7,
        "transactionCount": 1,
      },
      {
        "categoryId": "cat_008",
        "categoryName": "Education",
        "icon": "school",
        "color": "#29B6F6",
        "amount": 6200.00,
        "percentage": 11.7,
        "transactionCount": 2,
      },
      {
        "categoryId": "cat_009",
        "categoryName": "Personal Care",
        "icon": "face",
        "color": "#AB47BC",
        "amount": 400.00,
        "percentage": 0.8,
        "transactionCount": 1,
      },
    ],
    "recentTransactions": [
      {
        "_id": "txn_001",
        "title": "Salary",
        "amount": 85000.00,
        "type": "income",
        "category": {
          "_id": "cat_income",
          "name": "Salary",
          "icon": "payments",
          "color": "#00C853",
        },
        "date": "2025-10-01T00:00:00Z",
        "description": "Monthly salary deposit",
      },
      {
        "_id": "txn_002",
        "title": "Grocery Shopping",
        "amount": 2500.00,
        "type": "expense",
        "category": {
          "_id": "cat_001",
          "name": "Food & Dining",
          "icon": "restaurant",
          "color": "#FF6B6B",
        },
        "date": "2025-10-01T10:30:00Z",
        "description": "Weekly groceries from Shwapno",
      },
      {
        "_id": "txn_003",
        "title": "Uber Ride",
        "amount": 350.00,
        "type": "expense",
        "category": {
          "_id": "cat_002",
          "name": "Transportation",
          "icon": "directions_car",
          "color": "#4ECDC4",
        },
        "date": "2025-10-01T14:15:00Z",
        "description": "Ride to office",
      },
      {
        "_id": "txn_004",
        "title": "Netflix Subscription",
        "amount": 800.00,
        "type": "expense",
        "category": {
          "_id": "cat_004",
          "name": "Entertainment",
          "icon": "movie",
          "color": "#95E1D3",
        },
        "date": "2025-09-30T08:00:00Z",
        "description": "Monthly subscription",
      },
      {
        "_id": "txn_005",
        "title": "Electricity Bill",
        "amount": 3200.00,
        "type": "expense",
        "category": {
          "_id": "cat_005",
          "name": "Bills & Utilities",
          "icon": "receipt",
          "color": "#F38181",
        },
        "date": "2025-09-28T16:45:00Z",
        "description": "September electricity bill",
      },
    ],
    "unreadNotifications": 3,
  };

  // Mock analytics data
  static final Map<String, dynamic> _analyticsData = {
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
        {
          "category": {
            "_id": "cat_003",
            "name": "Shopping",
            "icon": "shopping_bag",
            "color": "#FFD93D",
          },
          "amount": 14500.00,
          "percentage": 27.4,
          "transactionCount": 3,
          "budget": 12000.00,
          "budgetUtilization": 120.8,
        },
        {
          "category": {
            "_id": "cat_004",
            "name": "Entertainment",
            "icon": "movie",
            "color": "#95E1D3",
          },
          "amount": 2800.00,
          "percentage": 5.3,
          "transactionCount": 3,
          "budget": 5000.00,
          "budgetUtilization": 56.0,
        },
        {
          "category": {
            "_id": "cat_005",
            "name": "Bills & Utilities",
            "icon": "receipt",
            "color": "#F38181",
          },
          "amount": 6000.00,
          "percentage": 11.3,
          "transactionCount": 4,
          "budget": 7000.00,
          "budgetUtilization": 85.7,
        },
        {
          "category": {
            "_id": "cat_006",
            "name": "Healthcare",
            "icon": "local_hospital",
            "color": "#BA68C8",
          },
          "amount": 850.00,
          "percentage": 1.6,
          "transactionCount": 1,
          "budget": 3000.00,
          "budgetUtilization": 28.3,
        },
        {
          "category": {
            "_id": "cat_007",
            "name": "Fitness",
            "icon": "fitness_center",
            "color": "#FF7043",
          },
          "amount": 3000.00,
          "percentage": 5.7,
          "transactionCount": 1,
          "budget": 4000.00,
          "budgetUtilization": 75.0,
        },
        {
          "category": {
            "_id": "cat_008",
            "name": "Education",
            "icon": "school",
            "color": "#29B6F6",
          },
          "amount": 4850.00,
          "percentage": 9.2,
          "transactionCount": 2,
          "budget": 5000.00,
          "budgetUtilization": 97.0,
        },
      ],
      "monthlyTrend": [
        {"month": "2025-04", "income": 78000.00, "expense": 45000.00},
        {"month": "2025-05", "income": 80000.00, "expense": 48000.00},
        {"month": "2025-06", "income": 82000.00, "expense": 51000.00},
        {"month": "2025-07", "income": 85000.00, "expense": 52000.00},
        {"month": "2025-08", "income": 83000.00, "expense": 49000.00},
        {"month": "2025-09", "income": 85000.00, "expense": 52920.00},
      ],
    },
  };
}

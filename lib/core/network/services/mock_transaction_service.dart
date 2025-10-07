import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:techcare_assessment_app/core/logger/app_logger.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction.dart';
import 'package:techcare_assessment_app/features/transactions/domain/entities/transaction_filters.dart';

/// Mock service that simulates API responses for transactions with realistic delays
/// This eliminates the need for an external JSON server or asset loading
///
/// Benefits:
/// - No external server dependency
/// - No asset configuration needed
/// - Immediate setup for reviewers/evaluators
/// - Realistic API simulation with delays
/// - Easy to switch to real API later
@singleton
class MockTransactionService {
  // Simulate realistic network delays
  static const Duration _minDelay = Duration(milliseconds: 300);
  static const Duration _maxDelay = Duration(milliseconds: 800);

  // In-memory storage for runtime modifications (create, update, delete)
  List<Map<String, dynamic>>? _runtimeTransactions;
  List<Map<String, dynamic>>? _runtimeCategories;

  /// Get transactions list (either runtime modified or original mock data)
  List<Map<String, dynamic>> _getTransactions() {
    _runtimeTransactions ??= List<Map<String, dynamic>>.from(_mockTransactions);
    return _runtimeTransactions!;
  }

  /// Get categories list (either runtime modified or original mock data)
  List<Map<String, dynamic>> _getCategories() {
    _runtimeCategories ??= List<Map<String, dynamic>>.from(_mockCategories);
    return _runtimeCategories!;
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

  /// Apply filters to transactions
  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> transactions,
    TransactionFilters? filters,
  ) {
    if (filters == null || !filters.hasActiveFilters) {
      return transactions;
    }

    return transactions.where((transaction) {
      // Date range filter
      if (filters.startDate != null || filters.endDate != null) {
        final date = DateTime.parse(transaction['date'] as String);
        if (filters.startDate != null && date.isBefore(filters.startDate!)) {
          return false;
        }
        if (filters.endDate != null && date.isAfter(filters.endDate!)) {
          return false;
        }
      }

      // Category filter
      if (filters.categoryIds.isNotEmpty) {
        final categoryId =
            (transaction['category'] as Map<String, dynamic>)['_id'] as String;
        if (!filters.categoryIds.contains(categoryId)) {
          return false;
        }
      }

      // Amount range filter
      final amount = transaction['amount'] as double;
      if (filters.minAmount != null && amount < filters.minAmount!) {
        return false;
      }
      if (filters.maxAmount != null && amount > filters.maxAmount!) {
        return false;
      }

      // Transaction type filter
      if (filters.type != null) {
        final type = TransactionType.fromString(transaction['type'] as String);
        if (type != filters.type) {
          return false;
        }
      }

      // Search query filter
      if (filters.searchQuery.isNotEmpty) {
        final query = filters.searchQuery.toLowerCase();
        final title = (transaction['title'] as String).toLowerCase();
        final description = ((transaction['description'] as String?) ?? '')
            .toLowerCase();
        final categoryName =
            ((transaction['category'] as Map<String, dynamic>)['name']
                    as String)
                .toLowerCase();

        if (!title.contains(query) &&
            !description.contains(query) &&
            !categoryName.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Fetches paginated transactions with filters
  Future<Map<String, dynamic>> getTransactions({
    required int page,
    required int pageSize,
    TransactionFilters? filters,
  }) async {
    await _simulateNetworkDelay();

    final allTransactions = _getTransactions();
    AppLogger.d(
      message:
          '🔍 MockService: Total transactions available: ${allTransactions.length}',
    );
    AppLogger.d(
      message:
          '🔍 MockService: Filters - hasActiveFilters: ${filters?.hasActiveFilters ?? false}',
    );

    // Apply filters
    final filteredTransactions = _applyFilters(allTransactions, filters);
    AppLogger.d(
      message:
          '🔍 MockService: After filtering: ${filteredTransactions.length}',
    );

    // Sort by date (newest first)
    filteredTransactions.sort((a, b) {
      final dateA = DateTime.parse(a['date'] as String);
      final dateB = DateTime.parse(b['date'] as String);
      return dateB.compareTo(dateA);
    });

    // Calculate pagination
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final total = filteredTransactions.length;
    final hasMore = endIndex < total;

    final paginatedData = filteredTransactions.sublist(
      startIndex,
      endIndex > total ? total : endIndex,
    );

    AppLogger.d(
      message:
          'Fetched page $page with ${paginatedData.length} transactions (Total: $total, HasMore: $hasMore)',
    );

    return {
      'transactions': paginatedData,
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }

  /// Fetches a single transaction by ID
  Future<Map<String, dynamic>?> getTransactionById(String id) async {
    await _simulateNetworkDelay();

    final allTransactions = _getTransactions();
    try {
      return allTransactions.firstWhere(
        (transaction) => transaction['_id'] == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Creates a new transaction
  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> transaction,
  ) async {
    await _simulateNetworkDelay();

    // Generate new ID
    final newTransaction = {
      ...transaction,
      '_id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
    };

    // Add to runtime storage
    final transactions = _getTransactions();
    transactions.insert(0, newTransaction);

    AppLogger.i(message: 'Created transaction: ${newTransaction['_id']}');
    return newTransaction;
  }

  /// Updates an existing transaction
  Future<Map<String, dynamic>?> updateTransaction(
    Map<String, dynamic> transaction,
  ) async {
    await _simulateNetworkDelay();

    AppLogger.d(
      message: '🔍 Looking for transaction with _id: ${transaction['_id']}',
    );
    AppLogger.d(message: '🔍 Received transaction data: $transaction');

    final transactions = _getTransactions();
    AppLogger.d(
      message: '🔍 Total transactions in storage: ${transactions.length}',
    );

    final index = transactions.indexWhere(
      (t) => t['_id'] == transaction['_id'],
    );

    if (index == -1) {
      AppLogger.e(
        message: '❌ Transaction not found with _id: ${transaction['_id']}',
      );
      AppLogger.d(
        message:
            '🔍 Available transaction IDs: ${transactions.map((t) => t['_id']).toList()}',
      );
      return null;
    }

    AppLogger.d(message: '✅ Found transaction at index: $index');
    AppLogger.d(message: '🔍 Original transaction: ${transactions[index]}');
    AppLogger.d(message: '🔍 New transaction data: $transaction');
    transactions[index] = transaction;
    AppLogger.i(message: '✅ Updated transaction: ${transaction['_id']}');
    AppLogger.d(message: '🔍 Returning transaction: $transaction');
    return transaction;
  }

  /// Deletes a transaction
  Future<bool> deleteTransaction(String id) async {
    await _simulateNetworkDelay();

    final transactions = _getTransactions();

    final initialLength = transactions.length;
    transactions.removeWhere((t) => t['_id'] == id);
    final removed = initialLength > transactions.length;
    AppLogger.i(message: 'Deleted transaction: $id (Success: $removed)');
    return removed;
  }

  /// Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    await _simulateNetworkDelay();
    return _getCategories();
  }

  // Mock data - matches the structure from db.json
  static final List<Map<String, dynamic>> _mockTransactions = [
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
    {
      "_id": "txn_006",
      "title": "Online Shopping",
      "amount": 4500.00,
      "type": "expense",
      "category": {
        "_id": "cat_003",
        "name": "Shopping",
        "icon": "shopping_bag",
        "color": "#FFD93D",
      },
      "date": "2025-09-27T20:30:00Z",
      "description": "Clothing from Daraz",
    },
    {
      "_id": "txn_007",
      "title": "Restaurant Dinner",
      "amount": 1800.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-09-26T19:00:00Z",
      "description": "Dinner at The Kabab Factory",
    },
    {
      "_id": "txn_008",
      "title": "Freelance Project",
      "amount": 15000.00,
      "type": "income",
      "category": {
        "_id": "cat_freelance",
        "name": "Freelance",
        "icon": "work",
        "color": "#00C853",
      },
      "date": "2025-09-25T12:00:00Z",
      "description": "Payment for mobile app project",
    },
    {
      "_id": "txn_009",
      "title": "Internet Bill",
      "amount": 1500.00,
      "type": "expense",
      "category": {
        "_id": "cat_005",
        "name": "Bills & Utilities",
        "icon": "receipt",
        "color": "#F38181",
      },
      "date": "2025-09-24T11:00:00Z",
      "description": "Monthly broadband bill",
    },
    {
      "_id": "txn_010",
      "title": "Coffee Shop",
      "amount": 450.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-09-23T09:30:00Z",
      "description": "Morning coffee at Barista",
    },
    {
      "_id": "txn_011",
      "title": "Gas Station",
      "amount": 2000.00,
      "type": "expense",
      "category": {
        "_id": "cat_002",
        "name": "Transportation",
        "icon": "directions_car",
        "color": "#4ECDC4",
      },
      "date": "2025-09-22T18:45:00Z",
      "description": "Fuel refill",
    },
    {
      "_id": "txn_012",
      "title": "Pharmacy",
      "amount": 850.00,
      "type": "expense",
      "category": {
        "_id": "cat_006",
        "name": "Healthcare",
        "icon": "local_hospital",
        "color": "#BA68C8",
      },
      "date": "2025-09-21T11:20:00Z",
      "description": "Medicine purchase",
    },
    {
      "_id": "txn_013",
      "title": "Gym Membership",
      "amount": 3000.00,
      "type": "expense",
      "category": {
        "_id": "cat_007",
        "name": "Fitness",
        "icon": "fitness_center",
        "color": "#FF7043",
      },
      "date": "2025-09-20T09:00:00Z",
      "description": "Monthly gym subscription",
    },
    {
      "_id": "txn_014",
      "title": "Book Purchase",
      "amount": 1200.00,
      "type": "expense",
      "category": {
        "_id": "cat_008",
        "name": "Education",
        "icon": "school",
        "color": "#29B6F6",
      },
      "date": "2025-09-19T15:30:00Z",
      "description": "Programming books from Rokomari",
    },
    {
      "_id": "txn_015",
      "title": "Lunch with Team",
      "amount": 2200.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-09-18T13:00:00Z",
      "description": "Team lunch at Pizza Hut",
    },
    {
      "_id": "txn_016",
      "title": "Mobile Recharge",
      "amount": 500.00,
      "type": "expense",
      "category": {
        "_id": "cat_005",
        "name": "Bills & Utilities",
        "icon": "receipt",
        "color": "#F38181",
      },
      "date": "2025-09-17T10:15:00Z",
      "description": "Prepaid mobile recharge",
    },
    {
      "_id": "txn_017",
      "title": "Movie Tickets",
      "amount": 1400.00,
      "type": "expense",
      "category": {
        "_id": "cat_004",
        "name": "Entertainment",
        "icon": "movie",
        "color": "#95E1D3",
      },
      "date": "2025-09-16T19:30:00Z",
      "description": "Cinema tickets for 2",
    },
    {
      "_id": "txn_018",
      "title": "Online Course",
      "amount": 5000.00,
      "type": "expense",
      "category": {
        "_id": "cat_008",
        "name": "Education",
        "icon": "school",
        "color": "#29B6F6",
      },
      "date": "2025-09-15T14:00:00Z",
      "description": "Flutter masterclass on Udemy",
    },
    {
      "_id": "txn_019",
      "title": "Bonus",
      "amount": 10000.00,
      "type": "income",
      "category": {
        "_id": "cat_bonus",
        "name": "Bonus",
        "icon": "card_giftcard",
        "color": "#00C853",
      },
      "date": "2025-09-14T00:00:00Z",
      "description": "Performance bonus",
    },
    {
      "_id": "txn_020",
      "title": "Grocery Shopping",
      "amount": 3200.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-09-13T11:45:00Z",
      "description": "Weekly groceries from Agora",
    },
    {
      "_id": "txn_021",
      "title": "Car Service",
      "amount": 4500.00,
      "type": "expense",
      "category": {
        "_id": "cat_002",
        "name": "Transportation",
        "icon": "directions_car",
        "color": "#4ECDC4",
      },
      "date": "2025-09-12T16:00:00Z",
      "description": "Car maintenance and oil change",
    },
    {
      "_id": "txn_022",
      "title": "Home Decor",
      "amount": 6500.00,
      "type": "expense",
      "category": {
        "_id": "cat_003",
        "name": "Shopping",
        "icon": "shopping_bag",
        "color": "#FFD93D",
      },
      "date": "2025-09-11T14:30:00Z",
      "description": "Furniture items from Otobi",
    },
    {
      "_id": "txn_023",
      "title": "Water Bill",
      "amount": 800.00,
      "type": "expense",
      "category": {
        "_id": "cat_005",
        "name": "Bills & Utilities",
        "icon": "receipt",
        "color": "#F38181",
      },
      "date": "2025-09-10T12:00:00Z",
      "description": "Monthly water bill",
    },
    {
      "_id": "txn_024",
      "title": "Fast Food",
      "amount": 950.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-09-09T20:15:00Z",
      "description": "Burger and fries from KFC",
    },
    {
      "_id": "txn_025",
      "title": "Spotify Premium",
      "amount": 600.00,
      "type": "expense",
      "category": {
        "_id": "cat_004",
        "name": "Entertainment",
        "icon": "movie",
        "color": "#95E1D3",
      },
      "date": "2025-09-08T08:30:00Z",
      "description": "Monthly music subscription",
    },
    {
      "_id": "txn_026",
      "title": "Rickshaw Fare",
      "amount": 120.00,
      "type": "expense",
      "category": {
        "_id": "cat_002",
        "name": "Transportation",
        "icon": "directions_car",
        "color": "#4ECDC4",
      },
      "date": "2025-09-07T17:20:00Z",
      "description": "Short distance travel",
    },
    {
      "_id": "txn_027",
      "title": "Haircut",
      "amount": 400.00,
      "type": "expense",
      "category": {
        "_id": "cat_009",
        "name": "Personal Care",
        "icon": "face",
        "color": "#AB47BC",
      },
      "date": "2025-09-06T11:00:00Z",
      "description": "Salon visit",
    },
    {
      "_id": "txn_028",
      "title": "Vegetables",
      "amount": 650.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-09-05T08:45:00Z",
      "description": "Fresh vegetables from market",
    },
    {
      "_id": "txn_029",
      "title": "Gift Purchase",
      "amount": 3500.00,
      "type": "expense",
      "category": {
        "_id": "cat_003",
        "name": "Shopping",
        "icon": "shopping_bag",
        "color": "#FFD93D",
      },
      "date": "2025-09-04T15:30:00Z",
      "description": "Birthday gift for friend",
    },
    {
      "_id": "txn_030",
      "title": "Consulting Fee",
      "amount": 8000.00,
      "type": "income",
      "category": {
        "_id": "cat_freelance",
        "name": "Freelance",
        "icon": "work",
        "color": "#00C853",
      },
      "date": "2025-09-03T00:00:00Z",
      "description": "Technical consulting payment",
    },
    {
      "_id": "txn_031",
      "title": "Coffee Shop",
      "amount": 450.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-09-02T09:30:00Z",
      "description": "Morning coffee and pastry",
    },
    {
      "_id": "txn_032",
      "title": "Fuel",
      "amount": 3200.00,
      "type": "expense",
      "category": {
        "_id": "cat_002",
        "name": "Transportation",
        "icon": "directions_car",
        "color": "#4ECDC4",
      },
      "date": "2025-09-01T18:00:00Z",
      "description": "Gas station fill-up",
    },
    {
      "_id": "txn_033",
      "title": "Freelance Project",
      "amount": 15000.00,
      "type": "income",
      "category": {
        "_id": "cat_freelance",
        "name": "Freelance",
        "icon": "work",
        "color": "#00C853",
      },
      "date": "2025-08-30T00:00:00Z",
      "description": "Web development project payment",
    },
    {
      "_id": "txn_034",
      "title": "Dinner Date",
      "amount": 2800.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-08-28T20:00:00Z",
      "description": "Restaurant dinner",
    },
    {
      "_id": "txn_035",
      "title": "Spa Treatment",
      "amount": 1500.00,
      "type": "expense",
      "category": {
        "_id": "cat_009",
        "name": "Personal Care",
        "icon": "face",
        "color": "#AB47BC",
      },
      "date": "2025-08-27T14:30:00Z",
      "description": "Relaxation spa session",
    },
    {
      "_id": "txn_036",
      "title": "Pharmacy",
      "amount": 950.00,
      "type": "expense",
      "category": {
        "_id": "cat_006",
        "name": "Healthcare",
        "icon": "local_hospital",
        "color": "#BA68C8",
      },
      "date": "2025-08-25T11:00:00Z",
      "description": "Medication and vitamins",
    },
    {
      "_id": "txn_037",
      "title": "Laptop Accessories",
      "amount": 4500.00,
      "type": "expense",
      "category": {
        "_id": "cat_003",
        "name": "Shopping",
        "icon": "shopping_bag",
        "color": "#FFD93D",
      },
      "date": "2025-08-23T16:45:00Z",
      "description": "Mouse and keyboard",
    },
    {
      "_id": "txn_038",
      "title": "Monthly Bonus",
      "amount": 10000.00,
      "type": "income",
      "category": {
        "_id": "cat_bonus",
        "name": "Bonus",
        "icon": "card_giftcard",
        "color": "#00C853",
      },
      "date": "2025-08-22T00:00:00Z",
      "description": "Performance bonus",
    },
    {
      "_id": "txn_039",
      "title": "Concert Tickets",
      "amount": 3500.00,
      "type": "expense",
      "category": {
        "_id": "cat_004",
        "name": "Entertainment",
        "icon": "movie",
        "color": "#95E1D3",
      },
      "date": "2025-08-20T19:00:00Z",
      "description": "Live music concert",
    },
    {
      "_id": "txn_040",
      "title": "Grocery Run",
      "amount": 3200.00,
      "type": "expense",
      "category": {
        "_id": "cat_001",
        "name": "Food & Dining",
        "icon": "restaurant",
        "color": "#FF6B6B",
      },
      "date": "2025-08-18T10:30:00Z",
      "description": "Weekly groceries",
    },
    {
      "_id": "txn_041",
      "title": "Taxi Fare",
      "amount": 280.00,
      "type": "expense",
      "category": {
        "_id": "cat_002",
        "name": "Transportation",
        "icon": "directions_car",
        "color": "#4ECDC4",
      },
      "date": "2025-08-17T22:30:00Z",
      "description": "Late night taxi ride",
    },
    {
      "_id": "txn_042",
      "title": "Smartphone Bill",
      "amount": 1200.00,
      "type": "expense",
      "category": {
        "_id": "cat_005",
        "name": "Bills & Utilities",
        "icon": "receipt",
        "color": "#F38181",
      },
      "date": "2025-08-15T00:00:00Z",
      "description": "Monthly mobile plan",
    },
    {
      "_id": "txn_043",
      "title": "Book Purchase",
      "amount": 850.00,
      "type": "expense",
      "category": {
        "_id": "cat_008",
        "name": "Education",
        "icon": "school",
        "color": "#29B6F6",
      },
      "date": "2025-08-14T13:20:00Z",
      "description": "Programming books",
    },
    {
      "_id": "txn_044",
      "title": "Haircut",
      "amount": 600.00,
      "type": "expense",
      "category": {
        "_id": "cat_009",
        "name": "Personal Care",
        "icon": "face",
        "color": "#AB47BC",
      },
      "date": "2025-08-12T15:00:00Z",
      "description": "Monthly haircut",
    },
    {
      "_id": "txn_045",
      "title": "Freelance Design",
      "amount": 12000.00,
      "type": "income",
      "category": {
        "_id": "cat_freelance",
        "name": "Freelance",
        "icon": "work",
        "color": "#00C853",
      },
      "date": "2025-08-10T00:00:00Z",
      "description": "UI/UX design project",
    },
  ];

  static final List<Map<String, dynamic>> _mockCategories = [
    {
      "_id": "cat_001",
      "name": "Food & Dining",
      "icon": "restaurant",
      "color": "#FF6B6B",
      "budget": 20000.00,
      "type": "expense",
    },
    {
      "_id": "cat_002",
      "name": "Transportation",
      "icon": "directions_car",
      "color": "#4ECDC4",
      "budget": 15000.00,
      "type": "expense",
    },
    {
      "_id": "cat_003",
      "name": "Shopping",
      "icon": "shopping_bag",
      "color": "#FFD93D",
      "budget": 10000.00,
      "type": "expense",
    },
    {
      "_id": "cat_004",
      "name": "Entertainment",
      "icon": "movie",
      "color": "#95E1D3",
      "budget": 8000.00,
      "type": "expense",
    },
    {
      "_id": "cat_005",
      "name": "Bills & Utilities",
      "icon": "receipt",
      "color": "#F38181",
      "budget": 12000.00,
      "type": "expense",
    },
    {
      "_id": "cat_006",
      "name": "Healthcare",
      "icon": "local_hospital",
      "color": "#BA68C8",
      "budget": 5000.00,
      "type": "expense",
    },
    {
      "_id": "cat_007",
      "name": "Fitness",
      "icon": "fitness_center",
      "color": "#FF7043",
      "budget": 3000.00,
      "type": "expense",
    },
    {
      "_id": "cat_008",
      "name": "Education",
      "icon": "school",
      "color": "#29B6F6",
      "budget": 7000.00,
      "type": "expense",
    },
    {
      "_id": "cat_009",
      "name": "Personal Care",
      "icon": "face",
      "color": "#AB47BC",
      "budget": 2000.00,
      "type": "expense",
    },
    {
      "_id": "cat_income",
      "name": "Salary",
      "icon": "payments",
      "color": "#00C853",
      "budget": 0,
      "type": "income",
    },
    {
      "_id": "cat_freelance",
      "name": "Freelance",
      "icon": "work",
      "color": "#00C853",
      "budget": 0,
      "type": "income",
    },
    {
      "_id": "cat_bonus",
      "name": "Bonus",
      "icon": "card_giftcard",
      "color": "#00C853",
      "budget": 0,
      "type": "income",
    },
  ];
}

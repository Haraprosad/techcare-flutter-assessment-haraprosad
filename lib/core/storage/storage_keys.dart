class StorageKeys {
  StorageKeys._(); // Private constructor

  // Theme related keys
  static const String isDarkMode = 'isDarkMode';
  static const String themeColor = 'themeColor';

  // User preference keys (non-sensitive)
  static const String language = 'language';
  static const String notifications = 'notifications';
  static const String fontSize = 'fontSize';

  // Secure storage keys (sensitive data)
  static const String authToken = 'authToken';
  static const String refreshToken = 'refreshToken';
  static const String userId = 'userId';
  static const String userPin = 'userPin';
  static const String biometricEnabled = 'biometricEnabled';

  static const String isAuthenticated = 'isAuthenticated';
  static const String userRole = 'userRole';
  static const String userName = 'userName';
  static const String userEmail = 'userEmail';
  static const String userPhone = 'userPhone';

  // Cart related keys
  static const String cartToken = 'cartToken';

  // Dashboard cache keys (for Hive)
  static const String cachedDashboardData = 'dashboard_data';
  static const String cachedBalanceSummary = 'balance_summary';
  static const String dashboardCacheTimestamp = 'dashboard_timestamp';
  static const String balanceSummaryCacheTimestamp = 'balance_timestamp';
}

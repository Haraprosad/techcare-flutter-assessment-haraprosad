/// All the keys used for storing data locally.
///
/// Keeps storage keys in one place so we don't mistype them.
/// Organized by what type of storage they're used in.
class StorageKeys {
  StorageKeys._(); // Just a namespace, not a real class

  // Theme settings
  static const String isDarkMode = 'isDarkMode';
  static const String themeColor = 'themeColor';

  // User preferences (safe to store in SharedPreferences)
  static const String language = 'language';
  static const String notifications = 'notifications';
  static const String fontSize = 'fontSize';

  // Sensitive data (goes in SecureStorage)
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

  // Shopping cart stuff
  static const String cartToken = 'cartToken';

  // Hive cache keys for dashboard data
  static const String cachedDashboardData = 'dashboard_data';
  static const String cachedBalanceSummary = 'balance_summary';
  static const String dashboardCacheTimestamp = 'dashboard_timestamp';
  static const String balanceSummaryCacheTimestamp = 'balance_timestamp';
}

class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String profile = '/auth/profile';
  
  // Routers
  static const String routers = '/routers';
  static const String users = '/users';
  static String routerById(String id) => '/routers/$id';
  static String routerHealth(String id) => '/routers/$id/health';
  static String routerSystemInfo(String id) => '/routers/$id/system-info';
  static String routerStats(String id) => '/routers/$id/stats';
  static String routerHotspotProfiles(String id) => '/routers/$id/profiles/mikrotik';
  
  // Vouchers
  static const String vouchers = '/vouchers';
  static const String voucherStatistics = '/vouchers/statistics';
  static String voucherById(String id) => '/vouchers/$id';
  static String voucherActivate(String id) => '/vouchers/$id/activate';
  static String voucherSell(String id) => '/vouchers/$id/sell';
  
  // Profiles
  static const String profiles = '/profiles';
  static String profileById(String id) => '/profiles/$id';
  
  // Sales
  static const String salesChart = '/sales/chart';
  static const String salesHistory = '/sales/history';
  
  // Subscriptions
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String mySubscription = '/subscriptions/my';
  static const String requestSubscription = '/subscriptions/request';
}

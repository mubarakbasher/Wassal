class ApiEndpoints {
  // Base
  static const String baseUrl = 'http://localhost:3000';
  
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  
  // Routers
  static const String routers = '/routers';
  static String routerById(String id) => '/routers/$id';
  static String routerHealth(String id) => '/routers/$id/health';
  static String routerSystemInfo(String id) => '/routers/$id/system-info';
  
  // Vouchers
  static const String vouchers = '/vouchers';
  static const String voucherStatistics = '/vouchers/statistics';
  static String voucherById(String id) => '/vouchers/$id';
  static String voucherActivate(String id) => '/vouchers/$id/activate';
  static String voucherSell(String id) => '/vouchers/$id/sell';
  
  // Profiles
  static const String profiles = '/profiles';
  static String profileById(String id) => '/profiles/$id';
}

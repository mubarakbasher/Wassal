import 'package:hive_flutter/hive_flutter.dart';
import '../models/voucher_model.dart';

abstract class VoucherLocalDataSource {
  Future<void> cacheVouchers(List<VoucherModel> vouchers);
  Future<List<VoucherModel>> getCachedVouchers();
  Future<void> cacheStatistics(Map<String, dynamic> stats, {String? routerId});
  Future<Map<String, dynamic>?> getCachedStatistics({String? routerId});
  Future<void> clearCache();
  Future<DateTime?> getLastCacheTime();
}

class VoucherLocalDataSourceImpl implements VoucherLocalDataSource {
  static const String _vouchersBoxName = 'vouchers_cache';
  static const String _statsBoxName = 'voucher_stats_cache';
  static const String _metaBoxName = 'voucher_meta';
  
  late Box<Map> _vouchersBox;
  late Box<Map> _statsBox;
  late Box _metaBox;
  
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    
    _vouchersBox = await Hive.openBox<Map>(_vouchersBoxName);
    _statsBox = await Hive.openBox<Map>(_statsBoxName);
    _metaBox = await Hive.openBox(_metaBoxName);
    
    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  @override
  Future<void> cacheVouchers(List<VoucherModel> vouchers) async {
    await _ensureInitialized();
    
    // Clear existing cache
    await _vouchersBox.clear();
    
    // Store each voucher with its ID as key
    for (final voucher in vouchers) {
      await _vouchersBox.put(voucher.id, voucher.toJson());
    }
    
    // Update cache timestamp
    await _metaBox.put('lastVouchersCacheTime', DateTime.now().toIso8601String());
  }

  @override
  Future<List<VoucherModel>> getCachedVouchers() async {
    await _ensureInitialized();
    
    final vouchers = <VoucherModel>[];
    
    for (final key in _vouchersBox.keys) {
      final data = _vouchersBox.get(key);
      if (data != null) {
        try {
          vouchers.add(VoucherModel.fromJson(Map<String, dynamic>.from(data)));
        } catch (e) {
          // Skip invalid entries
        }
      }
    }
    
    return vouchers;
  }

  @override
  Future<void> cacheStatistics(Map<String, dynamic> stats, {String? routerId}) async {
    await _ensureInitialized();
    
    final key = routerId ?? 'all';
    await _statsBox.put(key, stats);
    await _metaBox.put('lastStatsCacheTime_$key', DateTime.now().toIso8601String());
  }

  @override
  Future<Map<String, dynamic>?> getCachedStatistics({String? routerId}) async {
    await _ensureInitialized();
    
    final key = routerId ?? 'all';
    final data = _statsBox.get(key);
    
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    
    return null;
  }

  @override
  Future<void> clearCache() async {
    await _ensureInitialized();
    
    await _vouchersBox.clear();
    await _statsBox.clear();
    await _metaBox.clear();
  }

  @override
  Future<DateTime?> getLastCacheTime() async {
    await _ensureInitialized();
    
    final timeStr = _metaBox.get('lastVouchersCacheTime');
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  /// Check if cache is stale (older than maxAge)
  Future<bool> isCacheStale({Duration maxAge = const Duration(minutes: 5)}) async {
    final lastCache = await getLastCacheTime();
    if (lastCache == null) return true;
    
    return DateTime.now().difference(lastCache) > maxAge;
  }
}

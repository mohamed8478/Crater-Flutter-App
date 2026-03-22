import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyDashboardCache = 'dashboard_cache';
  static const String _keyDashboardCacheTime = 'dashboard_cache_time';
  static const int _cacheDurationMinutes = 5;

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  /// Save dashboard data to cache
  Future<void> cacheDashboardData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(_keyDashboardCache, jsonString);
    await prefs.setInt(_keyDashboardCacheTime, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached dashboard data if still valid (within 5 minutes)
  Future<Map<String, dynamic>?> getCachedDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_keyDashboardCache);
    final cachedTime = prefs.getInt(_keyDashboardCacheTime);

    if (cachedJson == null || cachedTime == null) {
      return null;
    }

    final elapsedMinutes = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(cachedTime)).inMinutes;
    if (elapsedMinutes > _cacheDurationMinutes) {
      // Cache expired, delete it
      await prefs.remove(_keyDashboardCache);
      await prefs.remove(_keyDashboardCacheTime);
      return null;
    }

    return jsonDecode(cachedJson) as Map<String, dynamic>;
  }

  /// Clear dashboard cache
  Future<void> clearDashboardCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDashboardCache);
    await prefs.remove(_keyDashboardCacheTime);
  }
}

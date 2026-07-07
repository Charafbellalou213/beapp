import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_stats.dart';

/// Unico punto di accesso a `shared_preferences`. `UserStats` viene salvato
/// come singola stringa JSON: nessuna delle informazioni è sensibile (solo
/// aggregati come punti, calorie e passi), quindi non serve cifratura.
class StorageService {
  static const _usernameKey = 'beapp_username';
  static const _userStatsKey = 'beapp_user_stats';
  static const _preferredRouteLengthKey = 'beapp_preferred_route_length';

  Future<String?> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<UserStats?> loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userStatsKey);
    if (raw == null) return null;
    return UserStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatsKey, jsonEncode(stats.toJson()));
  }

  Future<String?> loadPreferredRouteLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredRouteLengthKey);
  }

  Future<void> savePreferredRouteLength(String routeLengthName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredRouteLengthKey, routeLengthName);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

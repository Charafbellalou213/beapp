import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_stats.dart';

class StorageService {
  static const _usernameKey = 'beapp_username';
  static const _userStatsKeyPrefix = 'beapp_user_stats_';
  static const _preferredRouteLengthKey = 'beapp_preferred_route_length';
  static const _impactAccessTokenKey = 'beapp_impact_access_token';
  static const _impactRefreshTokenKey = 'beapp_impact_refresh_token';
  static const _credentialsKey = 'beapp_credentials';
  static const _feedbackShownKey = 'beapp_feedback_shown';
  static const _feedbackLikedKey = 'beapp_feedback_liked';
  static const _feedbackRatingKey = 'beapp_feedback_rating';

  Future<String?> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<void> clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
  }

  Future<UserStats?> loadUserStats(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_userStatsKeyPrefix$username');
    if (raw == null) return null;
    return UserStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_userStatsKeyPrefix${stats.username}',
      jsonEncode(stats.toJson()),
    );
  }

  Future<String?> loadPreferredRouteLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredRouteLengthKey);
  }

  Future<void> savePreferredRouteLength(String routeLengthName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredRouteLengthKey, routeLengthName);
  }

  Future<String?> loadImpactAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_impactAccessTokenKey);
  }

  Future<String?> loadImpactRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_impactRefreshTokenKey);
  }

  Future<void> saveImpactTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_impactAccessTokenKey, accessToken);
    await prefs.setString(_impactRefreshTokenKey, refreshToken);
  }

  Future<void> clearImpactTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_impactAccessTokenKey);
    await prefs.remove(_impactRefreshTokenKey);
  }

  // Account locali, salvati come mappa username -> password.

  Future<Map<String, String>> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_credentialsKey);

    if (raw == null) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  Future<void> _saveCredentials(Map<String, String> credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_credentialsKey, jsonEncode(credentials));
  }

  Future<bool> usernameExists(String username) async {
    final credentials = await _loadCredentials();
    return credentials.containsKey(username);
  }

  Future<void> registerCredentials(String username, String password) async {
    final credentials = await _loadCredentials();
    credentials[username] = password;
    await _saveCredentials(credentials);
  }

  Future<bool> verifyCredentials(String username, String password) async {
    final credentials = await _loadCredentials();
    return credentials[username] == password;
  }

  Future<bool> hasShownFeedbackPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_feedbackShownKey) ?? false;
  }

  Future<void> saveFeedbackResponse({required bool liked, int? rating}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_feedbackShownKey, true);
    await prefs.setBool(_feedbackLikedKey, liked);

    if (rating != null) {
      await prefs.setInt(_feedbackRatingKey, rating);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

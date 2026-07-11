import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/daily_activity_summary.dart';
import '../utils/impact_config.dart';
import 'storage_service.dart';

class ImpactService {
  ImpactService({StorageService? storageService, http.Client? httpClient})
    : _storage = storageService ?? StorageService(),
      _client = httpClient ?? http.Client();

  final StorageService _storage;
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${ImpactConfig.baseUrl}$path');

  Future<bool> ping() async {
    try {
      final response = await _client
          .get(_uri(ImpactConfig.pingEndpoint))
          .timeout(ImpactConfig.requestTimeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login() async {
    if (ImpactConfig.username.isEmpty || ImpactConfig.password.isEmpty)
      return false;

    try {
      final response = await _client
          .post(
            _uri(ImpactConfig.tokenEndpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': ImpactConfig.username,
              'password': ImpactConfig.password,
            }),
          )
          .timeout(ImpactConfig.requestTimeout);

      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final access = json['access'] as String?;
      final refresh = json['refresh'] as String?;
      if (access == null || refresh == null) return false;

      await _storage.saveImpactTokens(
        accessToken: access,
        refreshToken: refresh,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() => _storage.clearImpactTokens();

  Future<bool> hasValidSession() async {
    final access = await _storage.loadImpactAccessToken();
    if (access == null) return false;
    return !_isExpired(access);
  }

  Future<bool> _ensureValidAccessToken() async {
    final access = await _storage.loadImpactAccessToken();
    if (access != null && !_isExpired(access)) return true;

    final refresh = await _storage.loadImpactRefreshToken();
    if (refresh == null || _isExpired(refresh)) return false;

    try {
      final response = await _client
          .post(
            _uri(ImpactConfig.refreshEndpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refresh}),
          )
          .timeout(ImpactConfig.requestTimeout);

      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccess = json['access'] as String?;
      if (newAccess == null) return false;

      await _storage.saveImpactTokens(
        accessToken: newAccess,
        refreshToken: refresh,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }

  Future<Map<String, dynamic>?> _authorizedGet(String path) async {
    final ok = await _ensureValidAccessToken();
    if (!ok) return null;

    final access = await _storage.loadImpactAccessToken();
    try {
      final response = await _client
          .get(_uri(path), headers: {'Authorization': 'Bearer $access'})
          .timeout(ImpactConfig.requestTimeout);

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  DateTime resolveAvailableDate([DateTime? referenceDate]) {
    final base = referenceDate ?? DateTime.now();
    if (ImpactConfig.usePreviousYearDemoData) {
      return DateTime(base.year - 1, base.month, base.day);
    }
    return DateTime(
      base.year,
      base.month,
      base.day,
    ).subtract(const Duration(days: 1));
  }

  // somma i campioni della giornata; se l'array è vuoto ritorna null e non 0
  Future<double?> _fetchDailyValue(
    String endpointBase,
    String day, {
    double unitDivisor = 1,
  }) async {
    final path = '$endpointBase${ImpactConfig.patientUsername}/day/$day/';
    final json = await _authorizedGet(path);
    if (json == null) return null;

    final data = json['data'];
    if (data is! Map<String, dynamic>) return null;

    final samples = data['data'];
    if (samples is! List || samples.isEmpty) return null;

    double sum = 0;
    var found = false;
    for (final sample in samples) {
      if (sample is Map && sample['value'] != null) {
        final parsed = double.tryParse(sample['value'].toString());
        if (parsed != null) {
          sum += parsed;
          found = true;
        }
      }
    }

    return found ? sum / unitDivisor : null;
  }

  String _formatDay(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<DailyActivitySummary> getDailyActivitySummary([
    DateTime? referenceDate,
  ]) async {
    final date = resolveAvailableDate(referenceDate);
    final day = _formatDay(date);

    final results = await Future.wait([
      _fetchDailyValue(ImpactConfig.caloriesEndpoint, day),
      _fetchDailyValue(ImpactConfig.stepsEndpoint, day),
      // i valori sembrano essere in centimetri, da qui il /100000 per avere i km
      _fetchDailyValue(ImpactConfig.distanceEndpoint, day, unitDivisor: 100000),
    ]);

    final calories = results[0];
    final steps = results[1];
    final distance = results[2];

    return DailyActivitySummary(
      date: date,
      totalCalories: calories ?? 0,
      totalSteps: (steps ?? 0).round(),
      totalDistanceKm: distance ?? 0,
      hasCaloriesData: calories != null,
      hasStepsData: steps != null,
      hasDistanceData: distance != null,
    );
  }
}

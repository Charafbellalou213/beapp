import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/api_config.dart';

/// Wrapper HTTP minimale: non lancia mai eccezioni verso il chiamante,
/// ritorna `null` in caso di rete assente, timeout o risposta non valida,
/// così il resto dell'app può sempre ripiegare su dati stimati/locali.
class ApiService {
  Future<Map<String, dynamic>?> getJson(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      final response = await http.get(uri, headers: _headers).timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> get _headers {
    final token = ApiConfig.apiToken;
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_tip_model.dart';

/// Repository responsible for fetching health tips from the public REST API.
/// API: https://api.adviceslip.com/advice
/// No API key required. Returns a random health tip on every call.
/// Uses only cross-platform APIs (no dart:io) so it works on Web, Android, iOS.
class HealthRepository {
  static const String _baseUrl = 'https://api.adviceslip.com/advice';

  /// Timeout duration for the HTTP request
  static const Duration _timeout = Duration(seconds: 10);

  /// Fetches a random health tip from the adviceslip API.
  /// Throws a descriptive [Exception] on any failure (network, server, parse).
  Future<HealthTipModel> fetchRandomTip() async {
    try {
      final response = await http
          .get(
            // Timestamp param forces a fresh response (adviceslip caches aggressively)
            Uri.parse('$_baseUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      // Validate the expected response structure
      if (!decoded.containsKey('slip')) {
        throw Exception('Unexpected API response format.');
      }

      final tip = HealthTipModel.fromJson(decoded);

      if (tip.content.trim().isEmpty) {
        throw Exception('Received an empty tip from the API.');
      }

      return tip;
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } on FormatException {
      throw Exception('Failed to parse API response.');
    } catch (e) {
      // Catches network errors on all platforms (web uses XMLHttpRequest errors,
      // mobile uses SocketException — both surface here as generic exceptions)
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('network') ||
          msg.contains('connection') ||
          msg.contains('xmlhttprequest') ||
          msg.contains('failed host lookup') ||
          e.runtimeType.toString() == 'SocketException') {
        throw Exception('No internet connection. Please check your network.');
      }
      rethrow;
    }
  }
}

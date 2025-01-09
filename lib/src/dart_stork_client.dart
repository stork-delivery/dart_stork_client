import 'dart:convert';

import 'package:dart_stork_client/dart_stork_client.dart';
import 'package:http/http.dart' as http;

/// {@template dart_stork_client}
/// Dart package to access Stork APIs
/// {@endtemplate}
class DartStorkClient {
  /// {@macro dart_stork_client}
  DartStorkClient({
    String? baseUrl,
    http.Client? client,
  })  : _baseUrl = baseUrl ?? 'https://stork.erickzanardoo.workers.dev',
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  /// Fetches app information by its ID.
  Future<StorkApp> getApp(int appId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/v1/apps/$appId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch app: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return StorkApp.fromJson(json);
  }

  /// Closes the client and cleans up resources.
  /// Only call this if you provided your own client.
  void dispose() {
    _client.close();
  }
}

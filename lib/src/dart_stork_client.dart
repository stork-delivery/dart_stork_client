import 'dart:convert';
import 'dart:typed_data';

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

  /// Downloads an artifact from an app and its version.
  Future<Uint8List> downloadArtifact({
    required int appId,
    required String version,
    required String platform,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/v1/apps/$appId/download/$version/$platform'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download artifact: ${response.statusCode}');
    }

    return response.bodyBytes;
  }

  /// Lists all news, paginated, from an app
  Future<List<StorkAppNews>> listNews({
    required int appId,
    required int page,
    required int perPage,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/v1/apps/$appId/news?page=$page&perPage=$perPage',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to list news: ${response.statusCode}');
    }

    return (json.decode(response.body) as List)
        .map((e) => StorkAppNews.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a single news from an app
  Future<StorkAppNews> getNews({
    required int appId,
    required int newsId,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/v1/apps/$appId/news/$newsId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get news: ${response.statusCode}');
    }

    return StorkAppNews.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  /// Closes the client and cleans up resources.
  /// Only call this if you provided your own client.
  void dispose() {
    _client.close();
  }
}

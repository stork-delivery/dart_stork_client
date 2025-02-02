// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_stork_client/dart_stork_client.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  group('DartStorkClient', () {
    late http.Client httpClient;
    late DartStorkClient client;

    setUp(() {
      httpClient = _MockHttpClient();
      client = DartStorkClient(client: httpClient);
    });

    test('can be instantiated', () {
      expect(DartStorkClient(), isNotNull);
    });

    group('getApp', () {
      test('makes correct http request', () async {
        when(
          () => httpClient.get(
            Uri.parse('https://stork.erickzanardoo.workers.dev/v1/apps/1'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'id': 1,
              'name': 'test',
              'versions': ['1.0.0'],
            }),
            200,
          ),
        );

        final app = await client.getApp(1);

        expect(app.id, equals(1));
        expect(app.name, equals('test'));
        expect(app.versions, equals(['1.0.0']));

        verify(
          () => httpClient.get(
            Uri.parse('https://stork.erickzanardoo.workers.dev/v1/apps/1'),
          ),
        ).called(1);
      });

      test('throws exception on non-200 response', () async {
        when(
          () => httpClient.get(
            Uri.parse('https://stork.erickzanardoo.workers.dev/v1/apps/1'),
          ),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        expect(
          () => client.getApp(1),
          throwsA(isA<Exception>()),
        );
      });

      test('uses custom base url when provided', () async {
        final customClient = DartStorkClient(
          baseUrl: 'https://custom.url',
          client: httpClient,
        );

        when(
          () => httpClient.get(
            Uri.parse('https://custom.url/v1/apps/1'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'id': 1,
              'name': 'test',
              'versions': ['1.0.0'],
            }),
            200,
          ),
        );

        await customClient.getApp(1);

        verify(
          () => httpClient.get(
            Uri.parse('https://custom.url/v1/apps/1'),
          ),
        ).called(1);
      });
    });

    group('dispose', () {
      test('closes the http client', () {
        when(() => httpClient.close()).thenReturn(null);

        client.dispose();

        verify(() => httpClient.close()).called(1);
      });
    });

    group('downloadArtifact', () {
      test('makes correct http request', () async {
        final testBytes = Uint8List.fromList([1, 2, 3, 4]);
        when(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/download/1.0.0/linux',
            ),
          ),
        ).thenAnswer((_) async => http.Response.bytes(testBytes, 200));

        final bytes = await client.downloadArtifact(
          appId: 1,
          version: '1.0.0',
          platform: 'linux',
        );

        expect(bytes, equals(testBytes));

        verify(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/download/1.0.0/linux',
            ),
          ),
        ).called(1);
      });

      test('throws exception on non-200 response', () async {
        when(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/download/1.0.0/linux',
            ),
          ),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        expect(
          () => client.downloadArtifact(
            appId: 1,
            version: '1.0.0',
            platform: 'linux',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('uses custom base url when provided', () async {
        final customClient = DartStorkClient(
          baseUrl: 'https://custom.url',
          client: httpClient,
        );

        when(
          () => httpClient.get(
            Uri.parse('https://custom.url/v1/apps/1/download/1.0.0/linux'),
          ),
        ).thenAnswer(
          (_) async => http.Response.bytes(
            Uint8List.fromList([1, 2, 3, 4]),
            200,
          ),
        );

        await customClient.downloadArtifact(
          appId: 1,
          version: '1.0.0',
          platform: 'linux',
        );

        verify(
          () => httpClient.get(
            Uri.parse('https://custom.url/v1/apps/1/download/1.0.0/linux'),
          ),
        ).called(1);
      });
    });

    group('listNews', () {
      test('makes correct http request and parses response', () async {
        when(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/news?page=1&perPage=10',
            ),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode([
              {
                'id': 1,
                'title': 'Test News',
                'content': 'Test Content',
                'createdAt': '2025-01-31T19:19:02Z',
              }
            ]),
            200,
          ),
        );

        final news = await client.listNews(
          appId: 1,
          page: 1,
          perPage: 10,
        );

        expect(news.length, equals(1));
        expect(news.first.id, equals(1));
        expect(news.first.title, equals('Test News'));
        expect(news.first.content, equals('Test Content'));

        verify(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/news?page=1&perPage=10',
            ),
          ),
        ).called(1);
      });

      test('throws exception on error response', () async {
        when(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/news?page=1&perPage=10',
            ),
          ),
        ).thenAnswer((_) async => http.Response('', 404));

        expect(
          () => client.listNews(
            appId: 1,
            page: 1,
            perPage: 10,
          ),
          throwsException,
        );
      });
    });

    group('getNews', () {
      test('makes correct http request and parses response', () async {
        when(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/news/1',
            ),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'id': 1,
              'title': 'Test News',
              'content': 'Test Content',
              'createdAt': '2025-01-31T19:19:02Z',
            }),
            200,
          ),
        );

        final news = await client.getNews(
          appId: 1,
          newsId: 1,
        );

        expect(news.id, equals(1));
        expect(news.title, equals('Test News'));
        expect(news.content, equals('Test Content'));

        verify(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/news/1',
            ),
          ),
        ).called(1);
      });

      test('throws exception on error response', () async {
        when(
          () => httpClient.get(
            Uri.parse(
              'https://stork.erickzanardoo.workers.dev/v1/apps/1/news/1',
            ),
          ),
        ).thenAnswer((_) async => http.Response('', 404));

        expect(
          () => client.getNews(
            appId: 1,
            newsId: 1,
          ),
          throwsException,
        );
      });
    });
  });
}

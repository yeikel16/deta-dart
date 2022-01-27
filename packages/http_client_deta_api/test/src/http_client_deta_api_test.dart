// ignore_for_file: prefer_const_constructors
import 'dart:convert' as convert;
import 'package:client_deta_api/client_deta_api.dart';
import 'package:http/http.dart' as http;
import 'package:http_client_deta_api/http_client_deta_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late final MockHttpClient mockHttpClient;
  late final HttpClientDetaApi client;

  setUpAll(() {
    mockHttpClient = MockHttpClient();
    client = HttpClientDetaApi(http: mockHttpClient);
  });

  const headers = <String, String>{
    'Accept': 'application/json',
    'X-API-Key': 'projectKey',
  };
  final url = Uri.parse('url-test.com');
  final item = <String, dynamic>{'key': 'key-object', 'name': 'Jhon'};
  final jsonResponse = <String, dynamic>{
    'processed': <String, dynamic>{
      'items': <dynamic>[
        item,
      ]
    },
    'failed': <String, dynamic>{
      'items': <dynamic>[],
    }
  };
  final dataResponse = convert.jsonEncode(jsonResponse);
  group('HttpClientDetaApi', () {
    test('can be instantiated', () {
      expect(client, isNotNull);
    });

    group('method get', () {
      test('should return `DetaResponse` when the request is completed',
          () async {
        when(() => mockHttpClient.get(url, headers: headers)).thenAnswer(
          (_) async => http.Response(dataResponse, 200),
        );

        expect(
          await client.get<Map<String, dynamic>>(url, headers: headers),
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(200),
              )
              .having(
                (response) => response.body,
                'body',
                equals(jsonResponse),
              ),
        );
      });

      test(
          'should throw `DetaError` when an error occurs in the request '
          'with the statusCode 400', () async {
        when(
          () => mockHttpClient.get(
            url,
            headers: headers,
          ),
        ).thenAnswer(
          (_) async => http.Response(
            convert.jsonEncode(<String, dynamic>{
              'errors': <dynamic>['Bad request']
            }),
            400,
          ),
        );

        expect(
          () => client.get<Map<String, dynamic>>(url, headers: headers),
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'body',
                  equals({
                    'errors': ['Bad request']
                  }),
                )
                .having(
                  (error) => error.response?.statusCode,
                  'statusCode',
                  equals(400),
                ),
          ),
        );
      });
      test(
          'should throw `DetaError` whit null `response` when an error occurs '
          'in the decode response', () async {
        when(
          () => mockHttpClient.get(
            url,
            headers: headers,
          ),
        ).thenAnswer(
          (_) async => http.Response(
            'bad errors',
            400,
          ),
        );

        expect(
          () => client.get<Map<String, dynamic>>(url, headers: headers),
          throwsA(
            isA<DetaError>()
                .having((error) => error.response, 'response', isNull),
          ),
        );
      });
    });

    group('method put', () {
      final putData = {
        'items': [item]
      };

      test(
          'should return `DetaResponse` when the request is completed '
          'with the statusCode 207', () async {
        when(
          () => mockHttpClient.put(
            url,
            headers: headers,
            body: convert.jsonEncode(putData),
          ),
        ).thenAnswer((_) async => http.Response(dataResponse, 207));

        final response = await client.put<Map<String, dynamic>>(
          url,
          headers: headers,
          data: putData,
        );

        expect(
          response,
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(207),
              )
              .having(
                (response) => response.body,
                'body',
                equals(jsonResponse),
              ),
        );
      });

      test(
          'should throw `DetaError` when an error occurs in the request '
          'with the statusCo de 400', () async {
        when(
          () => mockHttpClient.put(
            url,
            headers: headers,
            body: convert.jsonEncode(putData),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            convert.jsonEncode(<String, dynamic>{
              'errors': <dynamic>['Bad request']
            }),
            400,
          ),
        );

        final response = client.put<Map<String, dynamic>>(
          url,
          headers: headers,
          data: putData,
        );

        expect(
          response,
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'body',
                  equals({
                    'errors': ['Bad request']
                  }),
                )
                .having(
                  (error) => error.response?.statusCode,
                  'statusCode',
                  equals(400),
                ),
          ),
        );
      });
    });

    group('method delete', () {
      test(
          'should return `DetaResponse` when the request is completed '
          'with the statusCode 200', () async {
        final jsonResponse = {
          'key': 'key-object',
        };
        final dataResponse = convert.jsonEncode(jsonResponse);

        when(
          () => mockHttpClient.delete(
            url,
            headers: headers,
          ),
        ).thenAnswer(
          (_) async => http.Response(dataResponse, 200),
        );

        final response = await client.delete<Map<String, dynamic>>(
          url,
          headers: headers,
        );

        expect(
          response,
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(200),
              )
              .having(
                (response) => response.body,
                'body',
                equals(jsonResponse),
              ),
        );
      });

      test(
          'should throw `DetaError` when an error occurs in the request '
          'with the statusCo de 400', () async {
        when(
          () => mockHttpClient.delete(
            url,
            headers: headers,
          ),
        ).thenAnswer(
          (_) async => http.Response(
            convert.jsonEncode(<String, dynamic>{
              'errors': <dynamic>['Bad request']
            }),
            400,
          ),
        );

        final response = client.delete<Map<String, dynamic>>(
          url,
          headers: headers,
        );

        expect(
          response,
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'body',
                  equals({
                    'errors': ['Bad request']
                  }),
                )
                .having(
                  (error) => error.response?.statusCode,
                  'statusCode',
                  equals(400),
                ),
          ),
        );
      });
    });

    group('method post', () {
      final putData = {'item': item};
      test(
          'should return `DetaResponse` when the request is completed '
          'with the statusCode 201', () async {
        when(
          () => mockHttpClient.post(
            url,
            headers: headers,
            body: convert.jsonEncode(putData),
          ),
        ).thenAnswer(
          (_) async => http.Response(dataResponse, 201),
        );

        final response = await client.post<Map<String, dynamic>>(
          url,
          headers: headers,
          data: putData,
        );

        expect(
          response,
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(201),
              )
              .having(
                (response) => response.body,
                'body',
                equals(jsonResponse),
              ),
        );
      });

      test(
          'should throw `DetaError` when an error occurs in the request '
          'with the statusCo de 409', () async {
        when(
          () => mockHttpClient.post(
            url,
            headers: headers,
            body: convert.jsonEncode(putData),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            convert.jsonEncode(<String, dynamic>{
              'errors': <dynamic>['Key already exists']
            }),
            409,
          ),
        );

        final response = client.post<Map<String, dynamic>>(
          url,
          headers: headers,
          data: putData,
        );

        expect(
          response,
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'body',
                  equals({
                    'errors': ['Key already exists']
                  }),
                )
                .having(
                  (error) => error.response?.statusCode,
                  'statusCode',
                  equals(409),
                ),
          ),
        );
      });
    });

    group('method patch', () {
      final putData = {'set': item};
      test(
          'should return `DetaResponse` when the request is completed '
          'with the statusCode 200', () async {
        when(
          () => mockHttpClient.patch(
            url,
            headers: headers,
            body: convert.jsonEncode(putData),
          ),
        ).thenAnswer(
          (_) async => http.Response(dataResponse, 200),
        );

        final response = await client.patch<Map<String, dynamic>>(
          url,
          headers: headers,
          data: putData,
        );

        expect(
          response,
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(200),
              )
              .having(
                (response) => response.body,
                'body',
                equals(jsonResponse),
              ),
        );
      });

      test(
          'should throw `DetaError` when an error occurs in the request '
          'with the statusCo de 404', () async {
        when(
          () => mockHttpClient.patch(
            url,
            headers: headers,
            body: convert.jsonEncode(putData),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            convert.jsonEncode(<String, dynamic>{
              'errors': <dynamic>['Key not found']
            }),
            404,
          ),
        );

        final response = client.patch<Map<String, dynamic>>(
          url,
          headers: headers,
          data: putData,
        );

        expect(
          response,
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'body',
                  equals({
                    'errors': ['Key not found']
                  }),
                )
                .having(
                  (error) => error.response?.statusCode,
                  'statusCode',
                  equals(404),
                ),
          ),
        );
      });
    });
  });
}

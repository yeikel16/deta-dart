// ignore_for_file: prefer_const_constructors
import 'package:client_deta_api/client_deta_api.dart';
import 'package:dio/dio.dart';
import 'package:dio_client_deta_api/dio_client_deta_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late final MockDio mockDio;
  late final DioClientDetaApi api;

  setUpAll(() {
    mockDio = MockDio();
    api = DioClientDetaApi(dio: mockDio);
  });

  setUpAll(() {
    registerFallbackValue(Options());
  });

  const headers = <String, String>{
    'Accept': 'application/json',
    'X-API-Key': 'projectKey',
  };
  final uri = Uri(path: 'url-test.com');
  final data = {'name': 'Jhon'};
  final dataResponse = <String, dynamic>{'key': 'key-object', 'value': 'hello'};

  group('DetaDioWebApi', () {
    test('can be instantiated', () {
      expect(DioClientDetaApi(dio: MockDio()), isNotNull);
    });

    group('method `get`', () {
      test('should return `DetaResponse` when the request is completed',
          () async {
        when(
          () {
            return mockDio.getUri<Map<String, dynamic>>(
              uri,
              options: any<Options>(named: 'options'),
            );
          },
        ).thenAnswer(
          (_) async => Response(
            data: dataResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: uri.path),
          ),
        );

        expect(
          await api.get<Map<String, dynamic>>(uri, headers: headers),
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(200),
              )
              .having(
                (response) => response.body,
                'body',
                equals(dataResponse),
              ),
        );
      });

      test(
          'should throw `DetaError` when an error occurs in the request '
          'with the statusCode 400', () async {
        when(
          () => mockDio.getUri<Map<String, dynamic>>(
            uri,
            options: any<Options>(named: 'options'),
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: uri.path,
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Bad request']
              },
              statusCode: 400,
              requestOptions: RequestOptions(
                path: uri.path,
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        expect(
          () => api.get<Map<String, dynamic>>(uri, headers: headers),
          throwsA(
            isA<DetaError>().having(
              (error) => error.response?.body,
              'response',
              equals({
                'errors': ['Bad request']
              }),
            ),
          ),
        );
      });
    });

    group('method `put`', () {
      test('should return `DetaResponse` when the request is complete',
          () async {
        when(
          () => mockDio.putUri<Map<String, dynamic>>(
            uri,
            data: data,
            options: any<Options>(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: dataResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: uri.path),
          ),
        );

        expect(
          await api.put<Map<String, dynamic>>(
            uri,
            data: data,
            headers: headers,
          ),
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(200),
              )
              .having(
                (response) => response.body,
                'body',
                equals(dataResponse),
              ),
        );
      });

      test(
          'should throw DetaError when an error occurs in the request '
          'with the statusCode 401', () async {
        when(
          () => mockDio.putUri<Map<String, dynamic>>(
            uri,
            data: data,
            options: any<Options>(named: 'options'),
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: uri.path,
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Unauthorized']
              },
              statusCode: 401,
              requestOptions: RequestOptions(
                path: uri.path,
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        expect(
          () => api.put<Map<String, dynamic>>(
            uri,
            data: data,
            headers: headers,
          ),
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'responseBody',
                  equals({
                    'errors': ['Unauthorized']
                  }),
                )
                .having(
                  (error) => error.response?.statusCode,
                  'statusCode',
                  equals(401),
                ),
          ),
        );
      });
    });

    group('method `post`', () {
      test('should return `DetaResponse` when the request is complete',
          () async {
        when(
          () => mockDio.postUri<Map<String, dynamic>>(
            uri,
            data: data,
            options: any<Options>(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: dataResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: uri.path),
          ),
        );

        expect(
          await api.post<Map<String, dynamic>>(
            uri,
            data: data,
            headers: headers,
          ),
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(200),
              )
              .having(
                (response) => response.body,
                'body',
                equals(dataResponse),
              ),
        );
      });

      test(
          'should throw DetaError when an error occurs in the request '
          'with the statusCode 409', () async {
        when(
          () => mockDio.postUri<Map<String, dynamic>>(
            uri,
            data: data,
            options: any<Options>(named: 'options'),
          ),
        ).thenThrow(
          // genDioError(message: 'Key already exists', statusCode: 409),
          DioError(
            requestOptions: RequestOptions(
              path: uri.path,
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Key already exists']
              },
              statusCode: 409,
              requestOptions: RequestOptions(
                path: uri.path,
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        expect(
          () => api.post<Map<String, dynamic>>(
            uri,
            data: data,
            headers: headers,
          ),
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'reponseBody',
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

    group('method `delete`', () {
      test('should return `DetaResponse` when the request is complete',
          () async {
        when(
          () => mockDio.deleteUri<Map<String, dynamic>>(
            uri,
            data: data,
            options: any<Options>(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: dataResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: uri.path),
          ),
        );

        expect(
          await api.delete<Map<String, dynamic>>(
            uri,
            data: data,
            headers: headers,
          ),
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(200),
              )
              .having(
                (response) => response.body,
                'body',
                equals(dataResponse),
              ),
        );
      });

      test(
          'should throw `DetaError` when an error occurs in the request '
          'with statusCode 400', () async {
        when(
          () => mockDio.deleteUri<Map<String, dynamic>>(
            uri,
            data: data,
            options: any<Options>(named: 'options'),
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: uri.path,
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Bad request']
              },
              statusCode: 400,
              requestOptions: RequestOptions(
                path: uri.path,
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        expect(
          () => api.delete<Map<String, dynamic>>(
            uri,
            data: data,
            headers: headers,
          ),
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'reponseBody',
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

    group('method `patch`', () {
      test('should return `DetaResponse` when the request is complete',
          () async {
        when(
          () => mockDio.patchUri<Map<String, dynamic>>(
            uri,
            data: data,
            options: any<Options>(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: dataResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: uri.path),
          ),
        );

        expect(
          await api.patch<Map<String, dynamic>>(
            uri,
            data: data,
            headers: headers,
          ),
          isA<DetaResponse<Map<String, dynamic>>>()
              .having(
                (response) => response.statusCode,
                'statusCode',
                equals(200),
              )
              .having(
                (response) => response.body,
                'body',
                equals(dataResponse),
              ),
        );
      });

      test(
          'should throw DetaError when an error occurs in the request '
          'with the statusCode 404', () async {
        when(
          () => mockDio.patchUri<Map<String, dynamic>>(
            uri,
            data: data,
            options: any<Options>(named: 'options'),
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: uri.path,
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Key not found']
              },
              statusCode: 404,
              requestOptions: RequestOptions(
                path: uri.path,
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        expect(
          () => api.patch<Map<String, dynamic>>(
            uri,
            data: data,
            headers: headers,
          ),
          throwsA(
            isA<DetaError>()
                .having(
                  (error) => error.response?.body,
                  'reponseBody',
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

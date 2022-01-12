// ignore_for_file: prefer_const_constructors
import 'package:deta/deta.dart';
import 'package:deta/src/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late final Deta tDeta;
  late Dio mockDio;
  const tProjectId = 'project_id';
  const tProjectKey = 'project_key';
  const tBaseName = 'base_name';
  const tUrl = 'https://database.deta.sh/v1/$tProjectId/$tBaseName';

  setUpAll(() {
    mockDio = MockDio();
    tDeta = Deta(
      projectId: tProjectId,
      projectKey: tProjectKey,
      dio: mockDio,
    );
  });

  void whenPutEspecificType<E>(E data, [String? key]) {
    when(
      () => mockDio.put<Map<String, Map<String, List>>>(
        tUrl,
        options: any(named: 'options'),
        data: {
          'items': [
            if (data is Map)
              data
            else
              {
                if (key != null) 'key': key,
                'value': data,
              }
          ]
        },
      ),
    ).thenAnswer(
      (_) async => Response(
        data: <String, Map<String, List>>{
          'processed': {
            'items': <dynamic>[
              {
                if (key != null) 'key': key else 'key': '8vxiwhhad06m',
                'value': data,
              }
            ]
          }
        },
        statusCode: 207,
        requestOptions: RequestOptions(
          path: tUrl,
        ),
      ),
    );
  }

  group('Deta', () {
    test('can be instantiated', () {
      expect(tDeta, isNotNull);
    });
  });

  group('DetaBase', () {
    group('put', () {
      const tPutKey = '8vxiwhhad06m';
      test('when the key is not null', () async {
        whenPutEspecificType<String>('deta', 'custom_key');

        final base = tDeta.base(tBaseName);
        final put = await base.put('deta', key: 'custom_key');

        expect(put, equals({'key': 'custom_key', 'value': 'deta'}));
      });

      test('an `String` type into DB', () async {
        whenPutEspecificType<String>('hello');

        final base = tDeta.base(tBaseName);
        final put = await base.put('hello');

        expect(put, equals({'key': tPutKey, 'value': 'hello'}));
      });

      test('an `int` type into DB', () async {
        whenPutEspecificType<int>(16);

        final base = tDeta.base(tBaseName);
        final put = await base.put(16);

        expect(put, equals({'key': tPutKey, 'value': 16}));
      });
      test('an `double` type into DB', () async {
        whenPutEspecificType<double>(16.5);

        final base = tDeta.base(tBaseName);
        final put = await base.put(16.5);

        expect(put, equals({'key': tPutKey, 'value': 16.5}));
      });
      test('an `bool` type into DB', () async {
        whenPutEspecificType<bool>(true);

        final base = tDeta.base(tBaseName);
        final put = await base.put(true);

        expect(put, equals({'key': tPutKey, 'value': true}));
      });

      test('an `List` type into DB', () async {
        whenPutEspecificType<List>(<String>['hello', 'world']);

        final base = tDeta.base(tBaseName);
        final put = await base.put(<String>['hello', 'world']);

        expect(
          put,
          equals({
            'key': tPutKey,
            'value': <String>['hello', 'world']
          }),
        );
      });

      test('an `dynamic` type into DB', () async {
        whenPutEspecificType<dynamic>(<dynamic>['hello', 16, 16.5, true]);

        final base = tDeta.base(tBaseName);
        final put = await base.put(<dynamic>['hello', 16, 16.5, true]);

        expect(
          put,
          equals({
            'key': tPutKey,
            'value': <dynamic>['hello', 16, 16.5, true]
          }),
        );
      });
      test('an `map` type into DB', () async {
        whenPutEspecificType<Map>(
          <String, dynamic>{'hello': 16, 'world': 16.5},
        );

        final base = tDeta.base(tBaseName);
        final put =
            await base.put(<String, dynamic>{'hello': 16, 'world': 16.5});

        expect(
          put,
          equals({
            'key': tPutKey,
            'value': <String, dynamic>{'hello': 16, 'world': 16.5}
          }),
        );
      });

      test('should throw a `UnsupportedError` when is no a primitive object',
          () async {
        final tFakeObject = Options();
        final base = tDeta.base(tBaseName);

        expect(base.put(tFakeObject), throwsUnsupportedError);
      });

      test('should throw a `DetaExcepcion` when the key is a empty string',
          () async {
        when(
          () => mockDio.put<Map<String, dynamic>>(
            tUrl,
            options: any(named: 'options'),
            data: {
              'items': [
                <String, dynamic>{
                  'key': '',
                  'value': 'deta',
                }
              ]
            },
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: tUrl,
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <String>['Bad item']
              },
              statusCode: 400,
              requestOptions: RequestOptions(
                path: tUrl,
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        final base = tDeta.base(tBaseName);

        expect(
          () => base.put('deta', key: ''),
          throwsA(
            isA<DetaException>()
                .having((e) => e.message, 'message', const ['Bad item']),
          ),
        );
      });

      test(
          'should throw a `DetaUnauthorizedException`when the call '
          'is not authorized', () async {
        when(
          () => mockDio.put<Map<String, dynamic>>(
            tUrl,
            options: any(named: 'options'),
            data: {
              'items': [
                <String, dynamic>{
                  'key': '',
                  'value': 'deta',
                }
              ]
            },
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: tUrl,
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': ['Unauthorized']
              },
              statusCode: 401,
              requestOptions: RequestOptions(
                path: tUrl,
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        final base = tDeta.base(tBaseName);

        expect(
          () => base.put('deta', key: ''),
          throwsA(
            isA<DetaUnauthorizedException>()
                .having((e) => e.message, 'message', 'Unauthorized'),
          ),
        );
      });
    });
  });
}

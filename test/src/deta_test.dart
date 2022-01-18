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
  const tUrl = 'https://database.deta.sh/v1/$tProjectId/$tBaseName/items';

  setUpAll(() {
    mockDio = MockDio();
    tDeta = Deta(
      projectId: tProjectId,
      projectKey: tProjectKey,
      dio: mockDio,
    );
  });

  void whenPutEspecificType<E>(E data, {String? key}) {
    final items = <dynamic>[];

    if (data is Map) {
      items.add(data);
    } else {
      items.add(<String, dynamic>{
        if (key != null) 'key': key,
        'value': data,
      });
    }

    when(
      () => mockDio.put<Map<String, Map<String, List>>>(
        tUrl,
        options: any(named: 'options'),
        data: {'items': items},
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
        whenPutEspecificType<String>('deta', key: 'custom_key');

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

      test('should throw `DetaObjectException` when is not a primitive object',
          () {
        final tFakeObject = Options();
        final base = tDeta.base(tBaseName);

        expect(base.put(tFakeObject), throwsA(isA<DetaObjectException>()));
      });

      test('should throw `DetaExcepcion` when the key is a empty string',
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
                .having((e) => e.message, 'message', 'Bad item'),
          ),
        );
      });

      test(
          'should throw `DetaUnauthorizedException`when the call '
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

    group('putMany', () {
      final items = <String>['hello', 'world'];
      final itemsMap = items.map((e) {
        if (e is Map) {
          return e;
        }
        return {'value': e};
      }).toList();

      test('should throw `DetaException` when the list is greater than 25', () {
        final base = tDeta.base(tBaseName);

        expect(
          base.putMany(items: List.generate(26, (index) => index)),
          throwsA(
            isA<DetaException>().having(
              (a) => a.message,
              'message',
              'The size of the list is greater than 25',
            ),
          ),
        );
      });

      test(
          'should throw `DetaObjectException` when the list contains '
          'an invalid object', () {
        final base = tDeta.base(tBaseName);

        expect(
          () => base.putMany(items: <Object>['hello', 'world', Options()]),
          throwsA(isA<DetaObjectException>()),
        );
      });

      test('should return a list of items save in DB', () async {
        final answer = <dynamic>[
          {
            'key': '8vxiwhhad06m',
            'value': 'hello',
          },
          {
            'key': '8vxiwhhadass',
            'value': 'world',
          }
        ];

        when(
          () => mockDio.put<Map<String, Map<String, List>>>(
            tUrl,
            options: any(named: 'options'),
            data: {'items': itemsMap},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: <String, Map<String, List>>{
              'processed': {'items': answer}
            },
            statusCode: 207,
            requestOptions: RequestOptions(
              path: tUrl,
            ),
          ),
        );

        final base = tDeta.base(tBaseName);
        final result = await base.putMany(items: items);

        expect(
          result,
          equals(answer),
        );
      });

      test(
          'should throw `DetaUnauthorizedException`when the call '
          'is not authorized', () {
        when(
          () => mockDio.put<Map<String, Map<String, List>>>(
            tUrl,
            options: any(named: 'options'),
            data: {'items': itemsMap},
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
          () => base.putMany(items: items),
          throwsA(
            isA<DetaUnauthorizedException>()
                .having((e) => e.message, 'message', 'Unauthorized'),
          ),
        );
      });
    });
  });
}

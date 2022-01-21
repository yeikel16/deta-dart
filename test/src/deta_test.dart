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
  const tUrlBase = 'https://database.deta.sh/v1/$tProjectId/$tBaseName';
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
      () => mockDio.put<Map<String, dynamic>>(
        tUrl,
        options: any(named: 'options'),
        data: {'items': items},
      ),
    ).thenAnswer(
      (_) async => Response(
        data: <String, dynamic>{
          'processed': <String, dynamic>{
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
                'errors': <dynamic>['Bad item']
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
                'errors': <dynamic>['Unauthorized']
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
        const answer = <dynamic>[
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
          () => mockDio.put<Map<String, dynamic>>(
            tUrl,
            options: any(named: 'options'),
            data: {'items': itemsMap},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: <String, dynamic>{
              'processed': <String, dynamic>{'items': answer}
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
          () => mockDio.put<Map<String, dynamic>>(
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
                'errors': <dynamic>['Unauthorized']
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

    group('insert', () {
      test('an `int` type into DB', () async {
        const key = 'number1';
        const value = 16;

        when(
          () => mockDio.post<Map<String, dynamic>>(
            tUrl,
            options: any(named: 'options'),
            data: <String, dynamic>{
              'items': [
                {'key': key, 'value': value}
              ]
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            data: <String, dynamic>{
              'processed': <String, dynamic>{
                'items': <dynamic>[
                  {
                    'key': key,
                    'value': value,
                  }
                ]
              }
            },
            statusCode: 201,
            requestOptions: RequestOptions(path: tUrl),
          ),
        );

        final base = tDeta.base(tBaseName);
        final put = await base.insert(16, key: key);

        expect(put, equals({'key': 'number1', 'value': 16}));
      });

      test('should throw `DetaObjectException`when the key already exists', () {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            tUrl,
            options: any(named: 'options'),
            data: <String, dynamic>{
              'items': <dynamic>[
                {'value': 'hello'}
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
                'errors': <dynamic>['Key already exists']
              },
              statusCode: 409,
              requestOptions: RequestOptions(
                path: tUrl,
              ),
            ),
            error: DioErrorType.response,
          ),
        );
        final base = tDeta.base(tBaseName);

        expect(
          () => base.insert('hello'),
          throwsA(
            isA<DetaObjectException>()
                .having((e) => e.message, 'message', 'Key already exists'),
          ),
        );
      });
    });
    group('get', () {
      const key = 'book1';
      test('a stored item when the key is valid', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            Uri.encodeComponent('$tUrl/$key'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: <String, dynamic>{
              'key': key,
            },
            statusCode: 200,
            requestOptions: RequestOptions(
              path: Uri.encodeComponent('$tUrl/$key'),
            ),
          ),
        );

        final base = tDeta.base(tBaseName);
        final result = await base.get(key);

        expect(result, equals({'key': key}));
      });

      test(
          'should throw `DetaItemNotFoundException` when the key is not exists',
          () {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            Uri.encodeComponent('$tUrl/$key'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: Uri.encodeComponent('$tUrl/$key'),
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{'key': key},
              statusCode: 404,
              requestOptions: RequestOptions(
                path: Uri.encodeComponent('$tUrl/$key'),
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        final base = tDeta.base(tBaseName);

        expect(
          () => base.get(key),
          throwsA(
            isA<DetaItemNotFoundException>().having(
              (e) => e.message,
              'message',
              'Key $key was not found',
            ),
          ),
        );
      });
    });
    group('delete', () {
      const key = '100';
      test('a stored item', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            Uri.encodeComponent('$tUrl/$key'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: <String, dynamic>{
              'key': key,
            },
            statusCode: 200,
            requestOptions: RequestOptions(
              path: Uri.encodeComponent('$tUrl/$key'),
            ),
          ),
        );

        final base = tDeta.base(tBaseName);
        final result = await base.delete(key);

        expect(result, isTrue);
      });

      test('should throw `DetaException` when occurs an error in the call.',
          () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            Uri.encodeComponent('$tUrl/$key'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: Uri.encodeComponent('$tUrl/$key'),
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{'key': key},
              statusCode: 400,
              requestOptions: RequestOptions(
                path: Uri.encodeComponent('$tUrl/$key'),
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        final base = tDeta.base(tBaseName);

        expect(await base.delete(key), isFalse);
      });
    });

    group('update', () {
      const key = '100';
      const item = {'name': 'deta', 'email': 'hello@deta.com'};
      test('a stored item', () async {
        when(
          () => mockDio.patch<Map<String, dynamic>>(
            Uri.encodeComponent('$tUrl/$key'),
            options: any(named: 'options'),
            data: {'set': item},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: <String, dynamic>{'key': key, 'set': item},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: Uri.encodeComponent('$tUrl/$key'),
            ),
          ),
        );

        final base = tDeta.base(tBaseName);
        final result = await base.update(key: key, item: item);

        expect(result, equals(item));
      });

      test('should throw `DetaException` when the `key` is empty', () async {
        final base = tDeta.base(tBaseName);

        expect(
          () => base.update(key: '', item: <String, dynamic>{}),
          throwsA(
            isA<DetaException>()
                .having((e) => e.message, 'message', 'Key cannot be empty'),
          ),
        );
      });

      test(
          'should throw `DetaItemNotFoundException` '
          'when the key does not exist', () async {
        when(
          () => mockDio.patch<Map<String, dynamic>>(
            Uri.encodeComponent('$tUrl/$key'),
            options: any(named: 'options'),
            data: {'set': item},
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: Uri.encodeComponent('$tUrl/$key'),
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Key not found']
              },
              statusCode: 404,
              requestOptions: RequestOptions(
                path: Uri.encodeComponent('$tUrl/$key'),
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        final base = tDeta.base(tBaseName);

        expect(
          () => base.update(key: key, item: item),
          throwsA(
            isA<DetaItemNotFoundException>()
                .having((e) => e.message, 'message', 'Key not found'),
          ),
        );
      });

      test('should throw `DetaException` when updating or deleting the key ',
          () async {
        final data = {'key': key, 'user': item};

        when(
          () => mockDio.patch<Map<String, dynamic>>(
            Uri.encodeComponent('$tUrl/$key'),
            options: any(named: 'options'),
            data: {'set': data},
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: Uri.encodeComponent('$tUrl/$key'),
            ),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Bad Request: Can not update the key']
              },
              statusCode: 400,
              requestOptions: RequestOptions(
                path: Uri.encodeComponent('$tUrl/$key'),
              ),
            ),
            error: DioErrorType.response,
          ),
        );

        final base = tDeta.base(tBaseName);

        expect(
          () => base.update(key: key, item: data),
          throwsA(
            isA<DetaException>().having(
              (e) => e.message,
              'message',
              'Bad Request: Can not update the key',
            ),
          ),
        );
      });
    });

    group('fetch', () {
      const key = '100';
      const item = {'key': key, 'name': 'deta', 'email': 'hello@deta.sh'};
      const response = <String, dynamic>{
        'paging': {'size': 1, 'last': ''},
        'items': [item]
      };

      final detaQuery1 = DetaQuery('name').equalTo('Jhon');
      final detaQuery2 = DetaQuery('age').notEqualTo(24);

      const limit = 10;
      const last = 'last';

      test('all items when no parameters are passed', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            '$tUrlBase/query',
            options: any(named: 'options'),
            data: {
              'query': <Map<String, dynamic>>[],
              'limit': 1000,
              'last': ''
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            data: response,
            statusCode: 200,
            requestOptions: RequestOptions(path: '$tUrlBase/query'),
          ),
        );

        final base = tDeta.base(tBaseName);
        final result = await base.fetch();

        expect(result, equals(response));
      });

      test('some item when using the `query`', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            '$tUrlBase/query',
            options: any(named: 'options'),
            data: {
              'query': <Map<String, dynamic>>[
                detaQuery1.query,
                detaQuery2.query
              ],
              'limit': limit,
              'last': last
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            data: response,
            statusCode: 200,
            requestOptions: RequestOptions(path: '$tUrlBase/query'),
          ),
        );

        final base = tDeta.base(tBaseName);
        final result = await base.fetch(
          query: [detaQuery1, detaQuery2],
          limit: limit,
          last: last,
        );

        expect(result, equals(response));
      });

      test(
          'should throw `DetaException` '
          'when `limit` is less than 1', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            '$tUrlBase/query',
            options: any(named: 'options'),
            data: {'query': <Map<String, dynamic>>[], 'limit': 0, 'last': ''},
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(path: '$tUrlBase/query'),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Limit min value 1']
              },
              statusCode: 400,
              requestOptions: RequestOptions(path: '$tUrlBase/query'),
            ),
            error: DioErrorType.response,
          ),
        );

        final base = tDeta.base(tBaseName);

        expect(
          () => base.fetch(limit: 0),
          throwsA(
            isA<DetaException>()
                .having((e) => e.message, 'message', 'Limit min value 1'),
          ),
        );
      });

      test('should throw `DetaException` when query is made on the key ',
          () async {
        final wrongQuery = DetaQuery('key').equalTo('key');

        when(
          () => mockDio.post<Map<String, dynamic>>(
            '$tUrlBase/query',
            options: any(named: 'options'),
            data: {
              'query': <Map<String, dynamic>>[wrongQuery.query],
              'limit': 1000,
              'last': ''
            },
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(path: '$tUrlBase/query'),
            response: Response<Map<String, dynamic>>(
              data: <String, dynamic>{
                'errors': <dynamic>['Bad query']
              },
              statusCode: 400,
              requestOptions: RequestOptions(path: '$tUrlBase/query'),
            ),
            error: DioErrorType.response,
          ),
        );

        final base = tDeta.base(tBaseName);

        expect(
          () => base.fetch(query: [wrongQuery]),
          throwsA(
            isA<DetaException>().having(
              (e) => e.message,
              'message',
              'Bad query',
            ),
          ),
        );
      });
    });
  });
}

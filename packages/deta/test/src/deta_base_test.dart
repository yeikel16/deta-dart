import 'package:client_deta_api/client_deta_api.dart';
import 'package:deta/deta.dart';
import 'package:deta/src/exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClientDetaApi extends Mock implements ClientDetaApi {}

class FakeData extends Fake {}

void main() {
  late final Deta tDeta;
  late MockClientDetaApi mockClient;
  const tProjectId = 'project-id';
  const tProjectKey = '${tProjectId}_key';
  const tBaseName = 'base_name';
  const tUrlBase = 'https://database.deta.sh/v1/$tProjectId/$tBaseName';
  final tUrl =
      Uri.parse('https://database.deta.sh/v1/$tProjectId/$tBaseName/items');

  setUpAll(() {
    mockClient = MockClientDetaApi();
    tDeta = Deta(projectKey: tProjectKey, client: mockClient);
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
      () => mockClient.put<Map<String, dynamic>>(
        tUrl,
        headers: any<Map<String, String>>(named: 'headers'),
        data: {'items': items},
      ),
    ).thenAnswer(
      (_) async => DetaResponse(
        body: <String, dynamic>{
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
      ),
    );
  }

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
        final tFakeObject = FakeData();
        final base = tDeta.base(tBaseName);

        expect(base.put(tFakeObject), throwsA(isA<DetaObjectException>()));
      });

      test('should throw `DetaExcepcion` when the key is a empty string',
          () async {
        when(
          () => mockClient.put<Map<String, dynamic>>(
            tUrl,
            headers: any<Map<String, String>>(named: 'headers'),
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
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Bad item']
              },
              statusCode: 400,
            ),
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
          () => mockClient.put<Map<String, dynamic>>(
            tUrl,
            headers: any<Map<String, String>>(named: 'headers'),
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
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Unauthorized']
              },
              statusCode: 401,
            ),
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
          () => base.putMany(items: <Object>['hello', 'world', FakeData()]),
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
          () => mockClient.put<Map<String, dynamic>>(
            tUrl,
            headers: any<Map<String, String>>(named: 'headers'),
            data: {'items': itemsMap},
          ),
        ).thenAnswer(
          (_) async => DetaResponse(
            body: <String, dynamic>{
              'processed': <String, dynamic>{'items': answer}
            },
            statusCode: 207,
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
          () => mockClient.put<Map<String, dynamic>>(
            tUrl,
            headers: any<Map<String, String>>(named: 'headers'),
            data: {'items': itemsMap},
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Unauthorized']
              },
              statusCode: 401,
            ),
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
          () => mockClient.post<Map<String, dynamic>>(
            tUrl,
            headers: any<Map<String, String>>(named: 'headers'),
            data: <String, dynamic>{
              'item': <String, dynamic>{'key': key, 'value': value}
            },
          ),
        ).thenAnswer(
          (_) async => DetaResponse(
            body: <String, dynamic>{
              'key': key,
              'value': value,
            },
            statusCode: 201,
          ),
        );

        final base = tDeta.base(tBaseName);
        final put = await base.insert(16, key: key);

        expect(put, equals({'key': 'number1', 'value': 16}));
      });

      test('should throw `DetaObjectException`when the key already exists', () {
        when(
          () => mockClient.post<Map<String, dynamic>>(
            tUrl,
            headers: any<Map<String, String>>(named: 'headers'),
            data: <String, dynamic>{
              'item': <String, dynamic>{'value': 'hello'}
            },
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Key already exists']
              },
              statusCode: 409,
            ),
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
          () => mockClient.get<Map<String, dynamic>>(
            Uri.parse('${tUrl.toString()}/${Uri.encodeComponent(key)}'),
            headers: any<Map<String, String>>(named: 'headers'),
          ),
        ).thenAnswer(
          (_) async => DetaResponse(
            body: <String, dynamic>{
              'key': key,
            },
            statusCode: 200,
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
          () => mockClient.get<Map<String, dynamic>>(
            Uri.parse('${tUrl.toString()}/${Uri.encodeComponent(key)}'),
            headers: any<Map<String, String>>(named: 'headers'),
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{'key': key},
              statusCode: 404,
            ),
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
          () => mockClient.delete<Map<String, dynamic>>(
            Uri.parse('${tUrl.toString()}/${Uri.encodeComponent(key)}'),
            headers: any<Map<String, String>>(named: 'headers'),
          ),
        ).thenAnswer(
          (_) async => DetaResponse(
            body: <String, dynamic>{
              'key': key,
            },
            statusCode: 200,
          ),
        );

        final base = tDeta.base(tBaseName);
        final result = await base.delete(key);

        expect(result, isTrue);
      });

      test('should throw `DetaException` when occurs an error in the call.',
          () async {
        when(
          () => mockClient.delete<Map<String, dynamic>>(
            Uri.parse('${tUrl.toString()}/${Uri.encodeComponent(key)}'),
            headers: any<Map<String, String>>(named: 'headers'),
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{'key': key},
              statusCode: 400,
            ),
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
          () => mockClient.patch<Map<String, dynamic>>(
            Uri.parse('${tUrl.toString()}/${Uri.encodeComponent(key)}'),
            headers: any<Map<String, String>>(named: 'headers'),
            data: {'set': item},
          ),
        ).thenAnswer(
          (_) async => DetaResponse(
            body: <String, dynamic>{'key': key, 'set': item},
            statusCode: 200,
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
          () => mockClient.patch<Map<String, dynamic>>(
            Uri.parse('${tUrl.toString()}/${Uri.encodeComponent(key)}'),
            headers: any<Map<String, String>>(named: 'headers'),
            data: {'set': item},
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Key not found']
              },
              statusCode: 404,
            ),
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
          () => mockClient.patch<Map<String, dynamic>>(
            Uri.parse('${tUrl.toString()}/${Uri.encodeComponent(key)}'),
            headers: any<Map<String, String>>(named: 'headers'),
            data: {'set': data},
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Bad Request: Can not update the key']
              },
              statusCode: 400,
            ),
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
          () {
            return mockClient.post<Map<String, dynamic>>(
              Uri.parse('$tUrlBase/query'),
              headers: any<Map<String, String>>(named: 'headers'),
              data: {
                'query': <Map<String, dynamic>>[],
                'limit': 1000,
                'last': ''
              },
            );
          },
        ).thenAnswer(
          (_) async => DetaResponse(
            body: response,
            statusCode: 200,
          ),
        );

        final base = tDeta.base(tBaseName);
        final result = await base.fetch();

        expect(result, equals(response));
      });

      test('some item when using the `query`', () async {
        when(
          () => mockClient.post<Map<String, dynamic>>(
            Uri.parse('$tUrlBase/query'),
            headers: any<Map<String, String>>(named: 'headers'),
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
          (_) async => DetaResponse(body: response, statusCode: 200),
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
          () => mockClient.post<Map<String, dynamic>>(
            Uri.parse('$tUrlBase/query'),
            headers: any<Map<String, String>>(named: 'headers'),
            data: {'query': <Map<String, dynamic>>[], 'limit': 0, 'last': ''},
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Limit min value 1']
              },
              statusCode: 400,
            ),
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
          () => mockClient.post<Map<String, dynamic>>(
            Uri.parse('$tUrlBase/query'),
            headers: any<Map<String, String>>(named: 'headers'),
            data: {
              'query': <Map<String, dynamic>>[wrongQuery.query],
              'limit': 1000,
              'last': ''
            },
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Bad query']
              },
              statusCode: 400,
            ),
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

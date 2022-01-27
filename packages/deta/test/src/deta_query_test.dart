import 'package:deta/deta.dart';
import 'package:test/test.dart';

void main() {
  late DetaQuery query;
  const key = 'name';

  setUp(() {
    query = DetaQuery(key);
  });

  group('DetaQuery', () {
    test('equalTo', () {
      expect(
        query.equalTo('Jhon').query,
        equals(<String, dynamic>{key: 'Jhon'}),
      );
    });

    test('notEqualTo', () {
      expect(
        query.notEqualTo('Jhon').query,
        equals(<String, dynamic>{'$key?ne': 'Jhon'}),
      );
    });

    test('lessThan', () {
      expect(
        query.lessThan(16).query,
        equals(<String, dynamic>{'$key?lt': 16}),
      );
    });

    test('greaterThan', () {
      expect(
        query.greaterThan(18).query,
        equals(<String, dynamic>{'$key?gt': 18}),
      );
    });
    test('lessThanOrEqualTo', () {
      expect(
        query.lessThanOrEqualTo(22).query,
        equals(<String, dynamic>{'$key?lte': 22}),
      );
    });
    test('greaterThanOrEqualTo', () {
      expect(
        query.greaterThanOrEqualTo(28).query,
        equals(<String, dynamic>{'$key?gte': 28}),
      );
    });
    test('prefix', () {
      expect(
        query.prefix('coin').query,
        equals(<String, dynamic>{'$key?pfx': 'coin'}),
      );
    });

    test('range', () {
      expect(
        query.range(16, 28).query,
        equals(<String, dynamic>{
          '$key?r': [16, 28]
        }),
      );
    });
    test('contains', () {
      expect(
        query.contains('@deta.sh').query,
        equals(<String, dynamic>{'$key?contains': '@deta.sh'}),
      );
    });

    test('notContains', () {
      expect(
        query.notContains('@deta.sh').query,
        equals(<String, dynamic>{'$key?not_contains': '@deta.sh'}),
      );
    });

    test('and', () {
      expect(
        DetaQuery('email')
            .contains('@deta.sh')
            .and('name')
            .equalTo('Jhon')
            .query,
        equals(<String, dynamic>{'email?contains': '@deta.sh', 'name': 'Jhon'}),
      );
    });
  });
}

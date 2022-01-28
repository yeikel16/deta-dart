import 'package:deta/src/exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('Exception', () {
    const tMessage = 'Bad request';
    group('DetaException toString', () {
      test('when have a message', () {
        const message = 'DetaException(message: $tMessage)';
        expect(
          const DetaException(message: tMessage).toString(),
          equals(message),
        );
      });

      test('when not have a message', () {
        expect(
          const DetaException().toString(),
          equals(
            '''
    DetaException:
    The request did not reach the server.
      Error cause:
      - DNS error
      - Network is not available
      - Request timed out.''',
          ),
        );
      });
    });

    test('DetaUnauthorizedException toString', () {
      const message = 'DetaUnauthorizedException(message: $tMessage)';
      expect(
        const DetaUnauthorizedException(message: tMessage).toString(),
        equals(message),
      );
    });

    test('DetaObjectException toString', () {
      const message = 'DetaObjectException(message: $tMessage)';
      expect(
        const DetaObjectException(message: tMessage).toString(),
        equals(message),
      );
    });

    test('DetaUnauthorizedException toString', () {
      const message = 'DetaUnauthorizedException(message: $tMessage)';
      expect(
        const DetaUnauthorizedException(message: tMessage).toString(),
        equals(message),
      );
    });

    test('DetaObjectException toString', () {
      const message = 'DetaObjectException(message: $tMessage)';
      expect(
        const DetaObjectException(message: tMessage).toString(),
        equals(message),
      );
    });

    test('DetaItemNotFoundException toString', () {
      const message = 'DetaItemNotFoundException(message: $tMessage)';
      expect(
        const DetaItemNotFoundException(message: tMessage).toString(),
        equals(message),
      );
    });
  });
}

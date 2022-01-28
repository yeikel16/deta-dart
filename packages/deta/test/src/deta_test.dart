import 'package:client_deta_api/client_deta_api.dart';
import 'package:deta/deta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClientDetaApi extends Mock implements ClientDetaApi {}

void main() {
  late final Deta tDeta;
  late MockClientDetaApi mockClient;
  const tProjectId = 'project-id';
  const tProjectKey = '${tProjectId}_key';

  setUpAll(() {
    mockClient = MockClientDetaApi();
    tDeta = Deta(projectKey: tProjectKey, client: mockClient);
  });

  group('Deta', () {
    test('can be instantiated', () {
      expect(tDeta, isNotNull);
    });

    test('get project id from proyect key parameter', () {
      expect(tProjectId, tDeta.projectId);
    });
  });
}

import 'dart:io';

import 'package:client_deta_api/client_deta_api.dart';
import 'package:deta/src/deta.dart';
import 'package:deta/src/exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClientDetaApi extends Mock implements ClientDetaApi {}

void main() {
  late final Deta tDeta;
  late final DetaDrive detaDrive;
  late MockClientDetaApi mockClient;

  const tProjectId = 'project-id';
  const tProjectKey = '${tProjectId}_key';
  const tDriveName = 'drive_name';
  const tBaseUrl = '$driveBaseUrl/$apiVersion/$tProjectId/$tDriveName';

  // ignore: prefer_const_constructors
  final model = DetaDriveResponse(
    name: 'file name',
    projectId: 'deta project id',
    driveName: 'deta drive_name',
  );

  setUpAll(() {
    mockClient = MockClientDetaApi();
    tDeta = Deta(projectKey: tProjectKey, client: mockClient);

    detaDrive = tDeta.drive(tDriveName);
  });

  group('DetaDrive', () {
    group('upload', () {
      const fileName = 'dart.png';
      final fileDart = File('example/assets/$fileName');

      final uploadUrl = Uri.parse('$tBaseUrl/files?name=$fileName');
      test('is successful when you get a statusCode 201', () async {
        final fileInBytes = await fileDart.readAsBytes();
        when(
          () => mockClient.post<Map<String, dynamic>>(
            uploadUrl,
            data: fileInBytes,
            headers: any<Map<String, String>>(named: 'headers'),
          ),
        ).thenAnswer(
          (_) async => DetaResponse<Map<String, dynamic>>(
            body: model.toJson(),
            statusCode: 201,
          ),
        );

        final response = await detaDrive.uploadFile(fileDart, fileName);

        expect(response, equals(model));
      });

      test(
          'should throw `DetaDriveExcepcion` when occurs a bad request '
          'and has a statusCode 400', () async {
        when(
          () => mockClient.post<Map<String, dynamic>>(
            uploadUrl,
            data: any(named: 'data'),
            headers: any<Map<String, String>>(named: 'headers'),
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Bad Request']
              },
              statusCode: 400,
            ),
          ),
        );

        expect(
          () => detaDrive.uploadFile(fileDart, fileName),
          throwsA(
            isA<DetaDriveException>()
                .having((e) => e.message, 'message', 'Bad Request'),
          ),
        );
      });

      test(
          'should throw `DetaDriveExcepcion` when occurs a bad request '
          'and has a statusCode 413', () async {
        when(
          () => mockClient.post<Map<String, dynamic>>(
            uploadUrl,
            data: any(named: 'data'),
            headers: any<Map<String, String>>(named: 'headers'),
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{
                'errors': <dynamic>['Request Entity Too Large']
              },
              statusCode: 413,
            ),
          ),
        );

        expect(
          () => detaDrive.uploadFile(fileDart, fileName),
          throwsA(
            isA<DetaDriveException>().having(
              (e) => e.message,
              'message',
              'Request Entity Too Large',
            ),
          ),
        );
      });

      test(
          'should throw `DetaUnauthorizedException`when the call '
          'is not authorized', () async {
        when(
          () => mockClient.post<Map<String, dynamic>>(
            uploadUrl,
            data: any(named: 'data'),
            headers: any<Map<String, String>>(named: 'headers'),
          ),
        ).thenThrow(
          DetaError(
            response: DetaResponse<Map<String, dynamic>>(
              body: <String, dynamic>{'error': 'Unauthorized'},
              statusCode: 401,
            ),
          ),
        );

        expect(
          () => detaDrive.uploadFile(fileDart, fileName),
          throwsA(
            isA<DetaUnauthorizedException>()
                .having((e) => e.message, 'message', 'Unauthorized'),
          ),
        );
      });
    });
  });

  group('DetaDriveResponse', () {
    final responseMissingKey = <String, dynamic>{
      'name': 'file name',
      'project_id': 'deta project id',
      'drive_name': 'deta drive_name'
    };

    final response = <String, dynamic>{
      'name': 'file name',
      'upload_id': 'a unique upload id',
      'project_id': 'deta project id',
      'drive_name': 'deta drive name'
    };

    test('fromJson', () {
      expect(model, DetaDriveResponse.fromJson(responseMissingKey));
    });
    test('toJson', () {
      expect(model.toJson(), equals(responseMissingKey));
      expect(DetaDriveResponse.fromJson(response).toJson(), equals(response));
    });

    test('toString', () {
      expect(
        model.toString(),
        equals(
          'DetaDriveResponse(name: ${model.name}, uploadId: ${model.uploadId}, '
          'projectId: ${model.projectId}, driveName: ${model.driveName})',
        ),
      );
    });
  });
}

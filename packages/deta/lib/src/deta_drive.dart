// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

part of 'deta.dart';

/// {@template drive}
/// An interface for interact with secure and scalable file storage service,
/// usign the service of the [Deta Drive](https://docs.deta.sh/docs/drive/about/).
/// {@endtemplate}
abstract class DetaDrive {
  /// {@macro drive}
  const DetaDrive();

  /// Upload a file.
  ///
  /// max upload file size using this method is 10Mb only
  Future<DetaDriveResponse> uploadFile(
    File file,
    String fileName, {
    String? directory,
    void Function(int progress, int total)? onSendProgress,
  });

  /// Upload a file larger than 10Mb.
  ///
  /// with chunked upload
  // Future<DetaDriveResponse> chunkedFileUpload(
  //   File file,
  //   String fileName, {
  //   String? directory,
  //   void Function(int progress, int total)? onSendProgress,
  // });

  /// Download a file.
  Future<DetaDriveResponse> downloadFile(
    String fileName, {
    void Function(int progress, int total)? onDownloadProgress,
  });

  /// Show a list of files save in the storage.
  Future<DetaDriveResponse> listFiles({
    int limit = 1000,
    String prefix = '',
    String last = '',
  });

  /// Remove files matching the name list.
  Future<DetaDriveResponse> deleteFiles(List<String> filenames);
}

// const _fileLimit = 10;

/// {@template deta_drive}
/// Implemtation of the [DetaDrive] interface.
///
/// https://drive.deta.sh/v1/{project_id}/{drive_name}
/// {@endtemplate}
class _DetaDrive extends DetaDrive {
  /// {@macro deta_drive}
  const _DetaDrive({
    required this.driveName,
    required this.deta,
    required this.client,
  });

  /// The `driveName` is the name given to your [DetaDrive].
  final String driveName;

  // Deta instance.
  final Deta deta;

  /// Client for http request.
  final ClientDetaApi client;

  Uri get driveUrl =>
      Uri.parse('$driveBaseUrl/$apiVersion/${deta.projectId}/$driveName');

  @override
  Future<DetaDriveResponse> uploadFile(
    File file,
    String fileName, {
    String? directory,
    void Function(int progress, int total)? onSendProgress,
  }) async {
    final fileInBytes = await file.readAsBytes();

    try {
      final resp = await client.post<Map<String, dynamic>>(
        Uri.parse('${driveUrl.toString()}/files?name=$fileName'),
        data: Stream.fromIterable(fileInBytes.toList().map((e) => [e])),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-API-Key': deta.projectKey,
          HttpHeaders.contentLengthHeader:
              fileInBytes.toList().length.toString()
        },
        onSendProgress: onSendProgress,
      );

      if (resp.statusCode == 201) {
        return DetaDriveResponse.fromJson(resp.body!);
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaDriveException();
  }

  @override
  Future<DetaDriveResponse> deleteFiles(List<String> filenames) async {
    try {
      final resp = await client.delete<Map<String, dynamic>>(
        Uri.parse(
          '${driveUrl.toString()}/files',
        ),
        data: {'names': filenames},
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-API-Key': deta.projectKey,
        },
      );

      if (resp.statusCode == 200) {
        // todo: verify proper response
        // return DetaDriveResponse.fromJson(resp.body!);
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaDriveException();
  }

  @override
  Future<DetaDriveResponse> downloadFile(
    String fileName, {
    void Function(int progress, int total)? onDownloadProgress,
  }) async {
    try {
      final resp = await client.get<List<int>>(
        Uri.parse(
          '${driveUrl.toString()}/files/download?name=$fileName',
        ),
        headers: <String, String>{
          'X-API-Key': deta.projectKey,
        },
        onReceiveProgress: onDownloadProgress,
      );

      if (resp.statusCode == 200) {
        // todo: file byte data,  verify proper response
        // return resp.data;
        // return DetaDriveResponse.fromJson(resp.body!);
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaDriveException();
  }

  @override
  Future<DetaDriveResponse> listFiles({
    int limit = 1000,
    String prefix = '',
    String last = '',
  }) async {
    try {
      final resp = await client.get<Map<String, dynamic>>(
        Uri.parse(
          '${driveUrl.toString()}/files?limit=$limit&prefix=$prefix&last=$last',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-API-Key': deta.projectKey,
        },
      );

      if (resp.statusCode == 200) {
        // todo: verify proper response for listFiles
        return DetaDriveResponse.fromJson(resp.body!);
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaDriveException();
  }

  Exception _handleError(DetaError e) {
    if (e.response != null && e.response?.body != null) {
      final data = e.response!.body as Map<String, dynamic>;

      if (e.response?.statusCode == 401) {
        return DetaUnauthorizedException(
          message: data['error'] as String? ?? 'Unauthorized',
        );
      }

      final message = _castListTo<String>(data)['errors']!.first;

      if (e.response!.statusCode == 400) {
        return DetaDriveException(message: message);
      }
      if (e.response!.statusCode == 413) {
        return const DetaDriveException(message: 'Request Entity Too Large');
      }
    }
    return const DetaException();
  }

  Map<String, List<E>> _castListTo<E>(Map<String, dynamic> itemMap) => itemMap
      .cast<String, List>()
      .map((key, value) => MapEntry(key, value.cast<E>()));
}

/// {@template deta_drive_response}
/// Response of the request in the service the [DetaDrive].
/// {@endtemplate}
class DetaDriveResponse {
  /// {@macro deta_drive_response}
  const DetaDriveResponse({
    required this.name,
    this.uploadId,
    required this.projectId,
    required this.driveName,
  });

  /// Decode `formJson`.
  factory DetaDriveResponse.fromJson(Map<String, dynamic> map) {
    return DetaDriveResponse(
      name: map['name'] as String,
      uploadId: map['upload_id'] as String?,
      projectId: map['project_id'] as String,
      driveName: map['drive_name'] as String,
    );
  }

  /// Name of file.
  final String name;

  /// Id of the file uploaded.
  final String? uploadId;

  /// Id of the proyect.
  final String projectId;

  /// Name of the [DetaDrive].
  final String driveName;

  /// Encode `toJson`.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        if (uploadId != null) 'upload_id': uploadId,
        'project_id': projectId,
        'drive_name': driveName,
      };

  @override
  String toString() {
    return 'DetaDriveResponse(name: $name, uploadId: $uploadId, '
        'projectId: $projectId, driveName: $driveName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DetaDriveResponse &&
        other.name == name &&
        other.uploadId == uploadId &&
        other.projectId == projectId &&
        other.driveName == driveName;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        uploadId.hashCode ^
        projectId.hashCode ^
        driveName.hashCode;
  }
}

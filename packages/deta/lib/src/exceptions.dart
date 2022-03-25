import 'dart:core';

/// {@template deta_excepction}
/// The exception is thrown when the request could not reach the server.
/// {@endtemplate}
class DetaException implements Exception {
  /// {@macro deta_excepction}
  const DetaException({this.message});

  /// The message of the exception.
  final String? message;

  @override
  String toString() {
    if (message != null) {
      return 'DetaException(message: $message)';
    }
    return '''
    DetaException:
    The request did not reach the server.
      Error cause:
      - DNS error
      - Network is not available
      - Request timed out.''';
  }
}

/// {@template deta_unauthorized_excepction}
/// The exception is thrown when an unauthorized request is made.
/// {@endtemplate}
class DetaUnauthorizedException implements Exception {
  /// {@macro deta_unauthorized_excepction}
  const DetaUnauthorizedException({required this.message});

  /// The message of the exception.
  final String message;

  @override
  String toString() => 'DetaUnauthorizedException(message: $message)';
}

/// {@template deta_object_exception}
/// The exception is thrown when the object is not soported.
/// {@endtemplate}
class DetaObjectException implements Exception {
  /// {@macro deta_object_exception}
  const DetaObjectException({required this.message});

  /// The message of the exception.
  final String message;

  @override
  String toString() => 'DetaObjectException(message: $message)';
}

/// {@template deta_item_not_found_exception}
/// The exception is thrown when the object is not found.
/// {@endtemplate}
class DetaItemNotFoundException implements Exception {
  /// {@macro deta_item_not_found_exception}
  const DetaItemNotFoundException({this.message = 'Key not found'});

  /// The message of the exception.
  final String message;

  @override
  String toString() => 'DetaItemNotFoundException(message: $message)';
}

/// {@template deta_drive_exception}
/// The exception is thrown when occur an error in drive service.
/// {@endtemplate}
class DetaDriveException implements Exception {
  /// {@macro deta_drive_exception}
  const DetaDriveException({this.message = 'Unknown'});

  /// The message of the exception.
  final String message;

  @override
  String toString() => 'DetaDriveException(message: $message)';
}

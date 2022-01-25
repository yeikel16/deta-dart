import 'package:deta_client_api/src/deta_response.dart';

/// {@template deta_client_api}
/// Base interface for the http client
/// {@endtemplate}
abstract class DetaClientApi {
  /// {@endtemplate}
  /// {@macro deta_client_api}
  const DetaClientApi();

  /// Make http `GET` request.
  Future<DetaResponse<T>> get<T>(
    Uri url, {
    Map<String, String> headers = const {},
  });

  /// Make http `POST` request.
  Future<DetaResponse<T>> post<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  });

  /// Make http `PUT` request.
  Future<DetaResponse<T>> put<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  });

  /// Make http `DELETE` request.
  Future<DetaResponse<T>> delete<T>(
    Uri url, {
    Object? data,
    Map<String, String> headers = const {},
  });

  /// Make http `PATCH` request.
  Future<DetaResponse<T>> patch<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  });
}

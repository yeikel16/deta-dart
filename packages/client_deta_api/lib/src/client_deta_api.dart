import 'package:client_deta_api/src/deta_response.dart';

/// {@template client_deta_api}
/// Basic interface of requests from a client to interact with the Deta API.
/// {@endtemplate}
abstract class ClientDetaApi {
  /// {@endtemplate}
  /// {@macro client_deta_api}
  const ClientDetaApi();

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

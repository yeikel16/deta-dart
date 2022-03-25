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
    ProgressRequestCallback? onReceiveProgress,
  });

  /// Make http `POST` request.
  Future<DetaResponse<T>> post<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
    ProgressRequestCallback? onSendProgress,
    ProgressRequestCallback? onReceiveProgress,
  });

  /// Make http `PUT` request.
  Future<DetaResponse<T>> put<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
    ProgressRequestCallback? onSendProgress,
    ProgressRequestCallback? onReceiveProgress,
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
    ProgressRequestCallback? onSendProgress,
    ProgressRequestCallback? onReceiveProgress,
  });
}

/// Callback to listen the progress for sending/receiving data.
///
/// [progress] is the length of the bytes have been sent/received.
///
/// [total] is the content length of the response/request body.
/// 1.When receiving data:
///   [total] is the request body length.
/// 2.When receiving data:
///   [total] will be -1 if the size of the response body is not known in
///   advance, for example: response data is compressed with gzip or no
///   content-length header.
/// [Dio](https://pub.dev/packages/dio) package.
typedef ProgressRequestCallback = void Function(int progress, int total);

import 'dart:typed_data';

import 'package:client_deta_api/client_deta_api.dart';
import 'package:dio/dio.dart';

/// {@template deta_dio_client_api}
/// Deta custom API client using [Dio] package for http request.
/// {@endtemplate}
class DioClientDetaApi extends ClientDetaApi {
  /// {@macro deta_dio_client_api}
  const DioClientDetaApi({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<DetaResponse<T>> get<T>(
    Uri url, {
    Map<String, String> headers = const {},
    ProgressRequestCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.getUri<T>(
        url,
        options: Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
      );

      return DetaResponse(body: response.data, statusCode: response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DetaResponse<T>> put<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
    ProgressRequestCallback? onSendProgress,
    ProgressRequestCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.putUri<T>(
        url,
        data: data,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return DetaResponse(body: response.data, statusCode: response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DetaResponse<T>> post<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
    ProgressRequestCallback? onSendProgress,
    ProgressRequestCallback? onReceiveProgress,
  }) async {
    Response<T> response;
    try {
      if (data is Uint8List) {
        response = await _dio.postUri<T>(
          url,
          data: Stream.fromIterable(data.toList().map((e) => [e])),
          options: Options(headers: headers),
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
      } else {
        response = await _dio.postUri<T>(
          url,
          data: data,
          options: Options(headers: headers),
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
      }

      return DetaResponse(body: response.data, statusCode: response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DetaResponse<T>> patch<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
    ProgressRequestCallback? onSendProgress,
    ProgressRequestCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patchUri<T>(
        url,
        data: data,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return DetaResponse(body: response.data, statusCode: response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DetaResponse<T>> delete<T>(
    Uri url, {
    Object? data,
    Map<String, String> headers = const {},
  }) async {
    try {
      final response = await _dio.deleteUri<T>(
        url,
        data: data,
        options: Options(headers: headers),
      );

      return DetaResponse(body: response.data, statusCode: response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioError e) => DetaError(
        response: DetaResponse<dynamic>(
          body: e.response?.data,
          statusCode: e.response?.statusCode,
        ),
      );
}

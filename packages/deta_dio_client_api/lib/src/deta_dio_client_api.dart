import 'package:deta_client_api/deta_client_api.dart';
import 'package:dio/dio.dart';

/// {@template deta_dio_client_api}
/// Deta custom client using [Dio] package for http request.
/// {@endtemplate}
class DetaDioClientApi extends DetaClientApi {
  /// {@macro deta_dio_client_api}
  const DetaDioClientApi({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<DetaResponse<T>> get<T>(
    Uri url, {
    Map<String, String> headers = const {},
  }) async {
    try {
      final response = await _dio.getUri<T>(
        url,
        options: Options(headers: headers),
      );

      return DetaResponse(response.data, response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DetaResponse<T>> put<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  }) async {
    try {
      final response = await _dio.putUri<T>(
        url,
        data: data,
        options: Options(headers: headers),
      );

      return DetaResponse(response.data, response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DetaResponse<T>> post<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  }) async {
    try {
      final response = await _dio.postUri<T>(
        url,
        data: data,
        options: Options(headers: headers),
      );

      return DetaResponse(response.data, response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DetaResponse<T>> patch<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  }) async {
    try {
      final response = await _dio.patchUri<T>(
        url,
        data: data,
        options: Options(headers: headers),
      );

      return DetaResponse(response.data, response.statusCode);
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

      return DetaResponse(response.data, response.statusCode);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  Error _handleError(DioError e) => DetaError(
        response: DetaResponse<dynamic>(
          e.response?.data,
          e.response?.statusCode,
        ),
      );
}

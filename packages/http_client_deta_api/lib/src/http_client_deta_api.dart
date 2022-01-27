import 'dart:convert';
import 'package:client_deta_api/client_deta_api.dart';
import 'package:http/http.dart' as http;

/// {@template http_client_deta_api}
/// Implementation of the `client_deta_api` package using the http package.
/// {@endtemplate}
class HttpClientDetaApi extends ClientDetaApi {
  /// {@macro http_client_deta_api}
  const HttpClientDetaApi({required http.Client http}) : _client = http;

  final http.Client _client;

  @override
  Future<DetaResponse<T>> delete<T>(
    Uri url, {
    Object? data,
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.delete(url, headers: headers, body: data);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as T;

      return DetaResponse<T>(
        body: jsonResponse,
        statusCode: response.statusCode,
      );
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<DetaResponse<T>> get<T>(
    Uri url, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as T;

      return DetaResponse<T>(
        body: jsonResponse,
        statusCode: response.statusCode,
      );
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<DetaResponse<T>> patch<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  }) async {
    final response =
        await _client.patch(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as T;

      return DetaResponse<T>(
        body: jsonResponse,
        statusCode: response.statusCode,
      );
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<DetaResponse<T>> post<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  }) async {
    final response =
        await _client.post(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body) as T;

      return DetaResponse<T>(
        body: jsonResponse,
        statusCode: response.statusCode,
      );
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<DetaResponse<T>> put<T>(
    Uri url, {
    Map<String, String> headers = const {},
    Object? data,
  }) async {
    final response =
        await _client.put(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 207) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

      return DetaResponse<T>(
        body: jsonResponse as T,
        statusCode: response.statusCode,
      );
    } else {
      throw _handleError(response);
    }
  }

  Exception _handleError(http.Response response) {
    try {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

      return DetaError(
        response: DetaResponse<dynamic>(
          body: jsonResponse,
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return DetaError();
    }
  }
}

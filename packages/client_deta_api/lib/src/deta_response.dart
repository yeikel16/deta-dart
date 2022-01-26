/// {@template deta_response}
/// Contains the information from the http response.
/// {@endtemplate}
class DetaResponse<T> {
  /// {@macro deta_response}
  DetaResponse(this.body, this.statusCode);

  /// Response body.
  final T? body;

  /// Http status code.
  final int? statusCode;
}

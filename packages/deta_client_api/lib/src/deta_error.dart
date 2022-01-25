///{@template deta_error}
/// Class for error in the request
/// {@endtemplate}
class DetaError extends Error {
  /// {@macro deta_error}
  DetaError({this.statusCode = 400, this.statusMessage = 'Bad request'});

  /// Error code
  final int statusCode;

  /// Error message
  final String statusMessage;
}

import 'package:client_deta_api/src/deta_response.dart';

///{@template deta_error}
/// Class for error in the request.
/// {@endtemplate}
class DetaError extends Error {
  /// {@macro deta_error}
  DetaError({this.response});

  /// Response info, it may be `null` if the request can't reach to
  /// the http server, for example, occurring a dns error,
  /// network is not available.
  DetaResponse? response;
}

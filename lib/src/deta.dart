import 'package:deta/src/exceptions.dart';
import 'package:dio/dio.dart';

/// {@template deta}
/// The Deta library is the easiest way to store and retrieve data from
/// your [Deta Base](https://docs.deta.sh/docs/base/sdk/).
/// {@endtemplate}
class Deta {
  /// {@macro deta}
  Deta({
    required this.projectId,
    required this.projectKey,
    required this.dio,
  });

  /// The `projectId` must to be provided for authentication.
  final String projectId;

  /// The proyect id.
  final String projectKey;

  /// Dio instance.
  final Dio dio;

}


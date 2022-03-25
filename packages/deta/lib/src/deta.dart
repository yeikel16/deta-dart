import 'dart:io';

import 'package:client_deta_api/client_deta_api.dart';
import 'package:deta/src/exceptions.dart';

part 'deta_drive.dart';
part 'deta_base.dart';
part 'deta_query.dart';

/// {@template deta}
/// The `Deta` library is the simple way to interact with the
/// services of the free clud on the [Deta](https://docs.deta.sh/) plataform.
/// {@endtemplate}
class Deta {
  /// {@macro deta}
  Deta({
    required this.projectKey,
    required this.client,
  }) : projectId = projectKey.split('_')[0];

  /// Project identifier.
  final String projectId;

  /// Must to be provided for authentication.
  final String projectKey;

  /// Client for http request.
  final ClientDetaApi client;

  /// Connect to a `DetaBase` from `baseName`.
  ///
  /// In case not exist it will be created instantly on first use
  DetaBase base(String baseName) => _DetaBase(
        client: client,
        deta: this,
        baseName: baseName,
      );

  /// Connect to a `DetaDrive` from `driveName`.
  ///
  /// In case not exist it will be created instantly on first use.
  /// Your data is encrypted and stored safely at rest. You have 10GB per
  /// Deta account. There is no limit on how many "Drives" you can create.
  DetaDrive drive(String driveName) => _DetaDrive(
        client: client,
        deta: this,
        driveName: driveName,
      );
}

/// Base URL for [DetaBase] API.
const baseUrl = 'https://database.deta.sh';

/// Base URL for [DetaDrive] API.
const driveBaseUrl = 'https://drive.deta.sh';

/// API version.
const apiVersion = 'v1';

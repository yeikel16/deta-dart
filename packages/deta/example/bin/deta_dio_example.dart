// ignore_for_file: avoid_print

import 'dart:io';

import 'package:deta/deta.dart';
import 'package:dio/dio.dart';
import 'package:dio_client_deta_api/dio_client_deta_api.dart';
import 'package:path/path.dart' as path;

const projectKey = 'put-your-proyect-key-here';

Future<void> main(List<String> args) async {
  // We declare class Deta, which receives our private credentials
  // as a parameter.
  // You can chouse a client that you want to use,
  // DioClietnDetaApi or HttpClientDetaApi, remember add to depencencies
  // the client.
  final deta = Deta(
    projectKey: projectKey,
    client: DioClientDetaApi(dio: Dio()),
  );

  // We define our `DetaDrive`, with witch we are going to work from the name.
  // In case `DetaDrive` not exist it will be created instantly on first use,
  // you can create as many `DetaDrive` as you need.
  final detaDrive = deta.drive('lenguages');

  final filePath = path.join(Directory.current.path, 'assets', 'dart.png');
  final fileName = path.basename(filePath);

  final file = File(filePath);
  print(filePath);

  // We upload a file to the `DetaDrive`
  final driveResponse = await detaDrive.uploadFile(
    file,
    fileName,
    onSendProgress: (progress, total) {
      if (total != -1) {
        final pos = progress / total * 1024;
        print('progress: ${pos.toStringAsFixed(2)} KB');
      }
    },
  );
  print(driveResponse);
}

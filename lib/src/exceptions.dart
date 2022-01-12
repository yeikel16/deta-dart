// ignore_for_file: public_member_api_docs
import 'dart:core';

class DetaException implements Exception {
  const DetaException({this.message = const ['Bad requests']});

  final List<String> message;
}

class DetaUnauthorizedException implements Exception {
  const DetaUnauthorizedException({required this.message});

  final String message;
}

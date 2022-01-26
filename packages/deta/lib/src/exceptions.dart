// ignore_for_file: public_member_api_docs
import 'dart:core';

class DetaException implements Exception {
  const DetaException({this.message = 'Bad requests'});

  final String message;
}

class DetaUnauthorizedException implements Exception {
  const DetaUnauthorizedException({required this.message});

  final String message;
}

class DetaObjectException implements Exception {
  const DetaObjectException({required this.message});

  final String message;
}

class DetaItemNotFoundException implements Exception {
  const DetaItemNotFoundException({this.message = 'Key not found'});

  final String message;
}

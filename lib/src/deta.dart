import 'package:deta/src/exceptions.dart';
import 'package:dio/dio.dart';

/// {@template deta}
/// The `Deta` library is the simple way to interact with the
/// services of the free clud on the [Deta](https://docs.deta.sh/) plataform.
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

  /// Returns a new instance of the `DetaBase` from the `baseName.`
  DetaBase base(String baseName) => _DetaBase(
        dio: dio,
        deta: this,
        baseName: baseName,
      );
}

/// {@template base}
/// An interface for interact with NoSQL database, usign the service of
/// the [Deta Base](https://docs.deta.sh/docs/base/about).
/// {@endtemplate}
abstract class DetaBase {
  /// {@macro base}
  const DetaBase();

  /// Stores an item in the database.
  ///
  /// It will update an item if the key already exists.
  /// In the case you do not provide us with a key, we will auto generate
  /// a 12 char long string as a key.
  Future<Map<String, dynamic>> put(Object item, {String? key});

  /// Stores a list if items in the database.
  ///
  /// It will update an item if the key already exists.
  Future<Map<String, dynamic>> putMany({required List<Object> items});

  /// Stores an item in the database but raises an error if the key
  /// already exists.
  ///
  /// Note that it checks if the item exists before saving
  /// to the db, consequently it is slower than [put].
  Future<Map<String, dynamic>> insert({String? key, required Object item});

  /// Retrieves an item from the database by its key.
  Future<Map<String, dynamic>> get({required String key});

  /// Retrieves multiple items from the database based on the
  /// provided (optional) filters.
  Future<Map<String, dynamic>> fetch(Map<String, dynamic> filters);

  /// Deletes an item from the database.
  Future<bool> delete({required String key});

  /// Updates an item in the database.
  Future<Map> update({required String key, required Object value});
}

/// Base URL for Deta API.
const baseUrl = 'https://database.deta.sh';

/// API version.
const apiVersion = 'v1';

/// {@template deta_base}
/// Implemtation of the [DetaBase] interface.
/// {@endtemplate}
class _DetaBase extends DetaBase {
  /// {@macro deta_base}
  const _DetaBase({
    required this.baseName,
    required this.deta,
    required this.dio,
  });

  /// The `baseName` is the name given to your database
  final String baseName;

  // https://database.deta.sh/v1/{project_id}/{base_name}

  // Deta instance.
  final Deta deta;

  /// Dio instance.
  final Dio dio;

  @override
  Future<Map<String, dynamic>> put(Object item, {String? key}) async {
    final map = <String, dynamic>{};

    if (key != null) {
      map['key'] = key;
    }

    if (item is Map) {
      map.addAll(item as Map<String, dynamic>);
    } else if (item is bool) {
      map['value'] = item;
    } else if (item is String) {
      map['value'] = item;
    } else if (item is int) {
      map['value'] = item;
    } else if (item is double) {
      map['value'] = item;
    } else if (item is List) {
      map['value'] = item;
    } else {
      throw DetaObjectException(
        message: '${item.runtimeType} is not supported. '
            'It is recommended to pass the object ${item.runtimeType} '
            'in the form of `Map`. '
            'Example: User(name: "John", age: 30) to `{name: "John", age: 30}`',
      );
    }

    try {
      final response = await dio.put<Map<String, dynamic>>(
        '$baseUrl/$apiVersion/${deta.projectId}/$baseName',
        options: _authorizationHeader(),
        data: {
          'items': [map],
        },
      );

      if (response.data != null) {
        final responseData = response.data!.cast<String, Map<String, List>>();

        return responseData['processed']!['items']![0] as Map<String, dynamic>;
      }
    } on DioError catch (e) {
      throw _handleError(e);
    }
    throw const DetaException();
  }

  @override
  Future<Map<String, dynamic>> insert({String? key, required Object item}) {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> putMany({required List<Object> items}) {
    // TODO: implement putMany
    throw UnimplementedError();
    throw const DetaException();
  }

  bool _checkValidObjectType(Object item) {
    if (item is Map) {
      return true;
    } else if (item is bool) {
      return true;
    } else if (item is String) {
      return true;
    } else if (item is int) {
      return true;
    } else if (item is double) {
      return true;
    } else if (item is List) {
      return true;
    } else {
      throw DetaObjectException(
        message: '${item.runtimeType} is not supported. '
            'It is recommended to pass the object ${item.runtimeType} '
            'in the form of `Map`. '
            'Example: User(name: "John", age: 30) to `{name: "John", age: 30}`',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> get({required String key}) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> update(
      {required String key, required Object value}) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<bool> delete({required String key}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> fetch(Map<String, dynamic> filters) {
    // TODO: implement fetch
    throw UnimplementedError();
  }

  Options _authorizationHeader() {
    return Options(
      headers: <String, dynamic>{
        'Accept': 'application/json',
        'X-API-Key': deta.projectId,
      },
    );
  }

  Exception _handleError(DioError e) {
    if (e.response != null) {
      final data = e.response!.data as Map<String, dynamic>;
      if (e.response!.statusCode == 400) {
        return DetaException(
          message: (data.cast<String, List<String>>())['errors']!.first,
        );
      }
      if (e.response!.statusCode == 401) {
        return DetaUnauthorizedException(
          message: (data.cast<String, List<String>>())['errors']!.first,
        );
      }
    }
    return const DetaException();
  }
}

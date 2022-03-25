part of 'deta.dart';

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
  /// Throw an `DetaException` if you attempt to put more than 25 items.
  Future<List<Map<String, dynamic>>> putMany({required List<Object> items});

  /// Stores an item in the database but raises an error if the key
  /// already exists.
  ///
  /// Note: The object to save must contain a key as parameter.
  ///
  /// Example:
  /// ```json
  ///  {
  ///   "key": "my-key",
  ///   "name": "Jhon Doe",
  ///   "age": 30
  ///  }
  /// ```
  /// Throw [DetaObjectException] if key already exists.
  Future<Map<String, dynamic>> insert(Object item, {String? key});

  /// Retrieves an item from the database by its key.
  Future<Map<String, dynamic>> get(String key);

  /// Retrieves multiple items from the database based on the
  /// provided (optional) filters.
  ///
  /// The [query] is list of [DetaQuery]. If omitted, you will get all the
  /// items in the database (up to 1mb or max 1000 items).
  /// The [limit] of the number of items you want to retreive, min value is 1.
  /// The [last] key seen in a previous paginated response.
  ///
  /// Throw [DetaException] if a query is made on the key or
  /// [limit] is less than 1.
  ///
  /// Example:
  /// ```dart
  /// final result await deta.base('my_base').fetch(
  ///   query: [DetaQuery('name').equalTo('Jhon')],
  /// );
  /// ```
  ///
  /// If you have a complex object which contains more objects,
  /// and you want to do the search by the parameters of the object
  /// that is inside another one, you can access it in a hierarchical way.
  ///
  /// Object User:
  ///
  /// ```json
  /// {
  ///   "key": "user-a",
  ///   "user": {
  ///     "username": "bev",
  ///     "profile": {
  ///       "age": 22,
  ///       "active": true,
  ///       "name": "Beverly"
  ///     },
  ///     "likes":["anime", "ramen"],
  ///     "purchases": 3
  ///   }
  /// }
  /// ```
  /// You can search by `name` and `age` in `profile` object like this:
  ///
  /// ```dart
  /// final result await deta.base('my_base').fetch(
  ///   query: [
  ///     DetaQuery('user.profile.age')
  ///       .equalTo(22).and('user.profile.name').equalTo('Beverly'),
  ///     ], limit: 10,
  ///   );
  ///```
  Future<Map<String, dynamic>> fetch({
    List<DetaQuery> query = const [],
    int limit = 1000,
    String last = '',
  });

  /// Deletes an item from the database.
  ///
  /// Return `true` regardless if an item with that key existed or not.
  Future<bool> delete(String key);

  /// Updates an item in the database.
  ///
  /// NOTE: In case you want to update only one parameter of your saved object,
  /// you must pass a new copy of the object with the updated values.
  ///
  /// Example:
  /// ```dart
  /// await deta.base('my_base').update('my_key', {'name': 'John Doe'});
  /// ```
  ///
  /// Throw [DetaException] when a bad request occurs.
  Future<Map> update({required String key, required Map item});
}

/// {@template deta_base}
/// Implemtation of the [DetaBase] interface.
/// {@endtemplate}
class _DetaBase extends DetaBase {
  /// {@macro deta_base}
  const _DetaBase({
    required this.baseName,
    required this.deta,
    required this.client,
  });

  /// The `baseName` is the name given to your database
  final String baseName;

  // Deta instance.
  final Deta deta;

  /// Client for http request.
  final ClientDetaApi client;

  Uri get itemsUrl =>
      Uri.parse('$baseUrl/$apiVersion/${deta.projectId}/$baseName/items');

  @override
  Future<Map<String, dynamic>> put(Object item, {String? key}) async {
    final map = <String, dynamic>{};

    if (key != null) {
      map['key'] = key;
    }

    _checkValidObjectType(item, map);

    try {
      final response = await client.put<Map<String, dynamic>>(
        itemsUrl,
        headers: _authorizationHeader(),
        data: {
          'items': [map],
        },
      );

      if (response.body != null) {
        final responseData = _castResponse(response.body!);

        return responseData['items']![0];
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaException();
  }

  @override
  Future<Map<String, dynamic>> insert(Object item, {String? key}) async {
    final map = <String, dynamic>{};

    if (key != null) {
      map['key'] = key;
    }

    _checkValidObjectType(item, map);

    try {
      final response = await client.post<Map<String, dynamic>>(
        itemsUrl,
        headers: _authorizationHeader(),
        data: <String, dynamic>{
          'item': map,
        },
      );

      if (response.body != null) return response.body!;
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaException();
  }

  @override
  Future<List<Map<String, dynamic>>> putMany({
    required List<Object> items,
  }) async {
    if (items.length > 25) {
      throw const DetaException(
        message: 'The size of the list is greater than 25',
      );
    }

    items.every((item) => _checkValidObjectType(item, <String, dynamic>{}));

    final result = items.map((e) {
      if (e is Map) {
        return e;
      }
      return {'value': e};
    }).toList();

    try {
      final response = await client.put<Map<String, dynamic>>(
        itemsUrl,
        headers: _authorizationHeader(),
        data: {
          'items': result,
        },
      );

      if (response.body != null) {
        final responseData = _castResponse(response.body!);

        return responseData['items']!;
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaException();
  }

  @override
  Future<Map<String, dynamic>> get(String key) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        Uri.parse('${itemsUrl.toString()}/${Uri.encodeComponent(key)}'),
        headers: _authorizationHeader(),
      );

      if (response.body != null) {
        return response.body!.cast<String, dynamic>();
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaException();
  }

  @override
  Future<Map<String, dynamic>> update({
    required String key,
    required Map item,
  }) async {
    if (key.isEmpty) {
      throw const DetaException(message: 'Key cannot be empty');
    }

    if (item.containsKey('key')) {
      item.remove('key');
    }

    try {
      final response = await client.patch<Map<String, dynamic>>(
        Uri.parse('${itemsUrl.toString()}/${Uri.encodeComponent(key)}'),
        headers: _authorizationHeader(),
        data: {'set': item},
      );

      if (response.body != null) {
        final resultUpdate =
            response.body!.cast<String, Map<String, dynamic>>();

        return resultUpdate['set']!;
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaException();
  }

  @override
  Future<bool> delete(String key) async {
    try {
      final response = await client.delete<Map<String, dynamic>>(
        Uri.parse('${itemsUrl.toString()}/${Uri.encodeComponent(key)}'),
        headers: _authorizationHeader(),
      );

      if (response.body != null) {
        final responseData = response.body!.cast<String, String>();

        return responseData['key']! == key;
      }
    } on DetaError catch (_) {
      return false;
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>> fetch({
    List<DetaQuery> query = const [],
    int limit = 1000,
    String last = '',
  }) async {
    final querys = <Map>[];

    if (query.isNotEmpty) {
      querys.addAll(query.map((e) => e.query));
    }

    try {
      final response = await client.post<Map<String, dynamic>>(
        Uri.parse('$baseUrl/$apiVersion/${deta.projectId}/$baseName/query'),
        headers: _authorizationHeader(),
        data: {'query': querys, 'limit': limit, 'last': last},
      );

      if (response.body != null) {
        return response.body!;
      }
    } on DetaError catch (e) {
      throw _handleError(e);
    }
    throw const DetaException();
  }

  Exception _handleError(DetaError e) {
    if (e.response != null && e.response?.body != null) {
      final data = e.response!.body as Map<String, dynamic>;

      if (e.response!.statusCode == 404) {
        final map = data.cast<String, Object>();
        if (map.containsKey('key')) {
          return DetaItemNotFoundException(
            message: 'Key ${map['key']} was not found',
          );
        } else {
          final message = _castListTo<String>(data)['errors']!.first;
          return DetaItemNotFoundException(message: message);
        }
      }

      final message = _castListTo<String>(data)['errors']!.first;

      if (e.response!.statusCode == 400) {
        return DetaException(message: message);
      }
      if (e.response!.statusCode == 401) {
        return DetaUnauthorizedException(message: message);
      }
      if (e.response!.statusCode == 409) {
        return DetaObjectException(message: message);
      }
    }
    return const DetaException();
  }

  /// Check if the object is valid
  bool _checkValidObjectType(Object item, Map<String, dynamic> map) {
    if (item is Map) {
      map.addAll(item as Map<String, dynamic>);
      return true;
    } else if (item is bool) {
      map['value'] = item;
      return true;
    } else if (item is String) {
      map['value'] = item;
      return true;
    } else if (item is int) {
      map['value'] = item;
      return true;
    } else if (item is double) {
      map['value'] = item;
      return true;
    } else if (item is List) {
      map['value'] = item;
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

  /// Return authorization header
  Map<String, String> _authorizationHeader() {
    return <String, String>{
      'Content-Type': 'application/json',
      'X-API-Key': deta.projectKey,
    };
  }

  Map<String, List<E>> _castListTo<E>(Map<String, dynamic> itemMap) => itemMap
      .cast<String, List>()
      .map((key, value) => MapEntry(key, value.cast<E>()));

  Map<String, List<Map<String, dynamic>>> _castResponse(
    Map<String, dynamic> data,
  ) {
    final castToMap = data.cast<String, Map<String, dynamic>>();
    final responseData =
        _castListTo<Map<String, dynamic>>(castToMap['processed']!);
    return responseData;
  }
}

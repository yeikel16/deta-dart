part of 'deta.dart';

/// {@template deta_query}
/// Create a query for search elements in the databese.
/// {@endtemplate}
class DetaQuery {
  ///{@macro deta_query}
  DetaQuery(this.key) : query = <String, dynamic>{};

  DetaQuery._withPreviousQuery(this.key, this.query);

  /// Key for indicate the search value.
  final String key;

  /// Query status.
  final Map<String, dynamic> query;

  /// Join the old query with a new one.
  DetaQuery and(String key) {
    return DetaQuery._withPreviousQuery(key, query);
  }

  /// Check the content of [key] is equal to [value].
  DetaQuery equalTo(Object value) {
    return _createQuery(value, '');
  }

  /// Check the content of [key] is not equal to [value].
  DetaQuery notEqualTo(Object value) {
    return _createQuery(value, '?ne');
  }

  /// Check the content of [key] is less than [value].
  DetaQuery lessThan(num value) {
    return _createQuery(value, '?lt');
  }

  /// Check the content of [key] is greater than [value].
  DetaQuery greaterThan(num value) {
    return _createQuery(value, '?gt');
  }

  /// Check the content of [key] isgreater than or equal to [value].
  DetaQuery greaterThanOrEqualTo(num value) {
    return _createQuery(value, '?gte');
  }

  /// Check the content of [key] is less than or equal to [value].
  DetaQuery lessThanOrEqualTo(num value) {
    return _createQuery(value, '?lte');
  }

  /// Check the content of [key] is a prefix equal to [value].
  DetaQuery prefix(String value) {
    return _createQuery(value, '?pfx');
  }

  /// Check the content of [key] in the range [start] and [end].
  DetaQuery range(num start, num end) {
    return _createQuery([start, end], '?r');
  }

  /// Check the content of [key] constains [value].
  ///
  /// NOTE: Only works for a list of strings, not apply to list
  /// of other data types.
  DetaQuery contains(String value) {
    return _createQuery(value, '?contains');
  }

  /// Check the content of [key] does not constain [value].
  ///
  /// NOTE: Only works for a list of strings, not apply to list
  /// of other data types.
  DetaQuery notContains(String value) {
    return _createQuery(value, '?not_contains');
  }

  DetaQuery _createQuery(Object value, String operator) {
    query['$key$operator'] = value;
    return DetaQuery._withPreviousQuery(key, query);
  }
}

# Example

```dart
// start deta instance using client `DioClientDetaApi`.
final deta = Deta(projectKey: projectKey, client: DioClientDetaApi(dio: Dio()));

// Connect to  the `lenguages` DetaBase.
final detabase = deta.base('lenguages');

// Get a spesific element form the key.
final item = await detabase.get('dart-g');

```

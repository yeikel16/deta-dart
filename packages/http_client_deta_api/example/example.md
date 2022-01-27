# Example

```dart
// start deta instance using client `HttpClientDetaApi`.
final deta = Deta(projectKey: projectKey, client: HttpClientDetaApi(dio: http.Client()));

// Connect to  the `lenguages` DetaBase.
final detabase = deta.base('lenguages');

// Get a spesific element form the key.
final item = await detabase.get('dart-g');

```

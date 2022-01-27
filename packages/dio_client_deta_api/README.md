# dio_client_deta_api

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

---

Implementation of the [client_deta_api](https://pub.dev/packages/client_deta_api) package using the [Dio](https://pub.dev/packages/dio) package.
This implementation is used as an **http request client** in the [deta](https://pub.dev/packages/deta) package that interacts with the [Deta](https://deta.sh) platform [API](https://docs.deta.sh/docs/base/http).

## Usage

```dart
// start deta instance using client `DioClientDetaApi`.
final deta = Deta(projectKey: projectKey, client: DioClientDetaApi(dio: Dio()));

// Connect to  the `lenguages` DetaBase.
final detabase = deta.base('lenguages');

// Get a spesific element form the key.
final item = await detabase.get('dart-g');

```

[dio_link]: https://pub.dev/packages/dio
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis

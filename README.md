# Deta

[![codecov][coverage_badge]][codecov_link]  [![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]   [![pub package][pub_badge]][pub_link]   [![License: MIT][license_badge]][license_link]

---

A Dart package to interact with the [HTTP API](https://docs.deta.sh/) of the free services of the [Deta](https://deta.sh/) plataform.

## Getting Started

Check the full example [here](https://github.com/yeikel16/deta-dart/blob/main/example/deta_base_example.dart).

### Install

Add to dependencies on `pubspec.yaml`:

```yaml
dependencies:
    deta: <version>
```

### Usege

We declare class **Deta**, which receives our private credential as a parameter.

```dart
  final deta = Deta(projectKey: 'projectKey', dio: Dio());
```

🚨  **WARNING** 🚨
Your `projectKey` is confidential and meant to be used by you. Anyone who has your project key can access your database. Please, do not share it or commit it in your code.

### DetaBase

`DetaBase` is a fully-managed, fast, scalable and secure NoSQL database with a focus on end-user simplicity.

We define our `DetaBase`, with witch we are going to interact through the `base` method that receives the name of the `DetaBase` as a parameter. In case not exist it will be created instantly on first use, you can create as many `DetaBase` as you need.

A `DetaBase` instance is a collection of data, not unlike a Key-Value store, a MongoDB collection or a PostgreSQL/MySQL table.

```dart
  final detabase = deta.base('lenguages');
```

#### Methods

##### put

Save an item. It will update an item if the key already exists.
  
```dart  
  await detabase.put({
    'key': 'dart-g',
    'name': 'Dart',
    'description':
        'Dart is a general-purpose programming language that adds strong '
            'support for modularity, co-variant return types, and a strong '
            'emphasis on type safety.',
    'creator': 'Google',
    'year': 2012,
  });
```

##### putMany

Saves a list the elements, this list can only have a maximum of 20 element.

```dart
  await detabase.putMany(
    items: lenguages.map((lenguage) => lenguage.toJson()).toList(),
  );
```

##### insert

Saves an element like `put`, with the difference that if this element exists in `DetaBase` it will throw an `DetaObjectException`. The `key` required that are part of the elemet to be saved.

```dart
  await detabase.insert({
    'key': 'r-f',
    'name': 'R',
    'description': 'R is a programming language and software environment '
        'for statistical computing and graphics.',
    'creator': 'R Foundation',
    'year': 1995,
  });
```

##### update

Update the element from the supplied `key`, you have to pass the whole element, both the updated and unchanged parameters.

```dart
  await detabase.update(
    key: 'ruby-ym',
    item: <String, dynamic>{
      'key': 'ruby-ym',
      'name': 'Ruby',
      'description': 'Ruby is a dynamic, open source, general-purpose '
          'programming language with a focus on simplicity and productivity.',
      'creator': 'Yukihiro Matsumoto',
      'year': 1995,
    },
  );
```

##### get

Get a spesific element form the key.

```dart
  final item = await detabase.get('dart-g');
```

##### delete

Delete a spesific element from the key.

```dart
  final wasDeleted = await detabase.delete('ruby');
```

##### fetch

Return all saved items if no `query` is specified.

```dart
  final all = await detabase.fetch();
```

Return all element that matched the indicated `query`.

  ```dart
  final result = await detabase.fetch(
    query: [DetaQuery('year').lessThanOrEqualTo(2000).and('name').prefix('C')],
  );
  ```

---

## Running Tests 🧪

To run all unit tests use the following command:

```sh
flutter test --coverage --test-randomize-ordering-seed random

```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report in Mac or Linux
$ open coverage/index.html # 
```

``` powershell
# Open Coverage Report in Windows
 Invoke-Expression coverage/index.html # 
```

---

A Very Good Project created by [Very Good CLI](https://github.com/VeryGoodOpenSource/very_good_cli).

[codecov_link]: https://codecov.io/gh/yeikel16/deta-dart
[coverage_badge]: https://codecov.io/gh/yeikel16/deta-dart/branch/main/graph/badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[pub_badge]: https://img.shields.io/pub/v/deta.svg
[pub_link]: https://pub.dartlang.org/packages/deta
[license_link]: https://opensource.org/licenses/MIT
[logo]: https://docs.deta.sh/img/logo.svg
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis

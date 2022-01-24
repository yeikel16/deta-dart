// ignore_for_file: unused_local_variable

import 'package:deta/deta.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

const projectKey = 'put-your-proyect-key-here';

Future<void> main(List<String> args) async {
  // We declare class Deta, which receives our private credentials
  // as a parameter.
  final deta = Deta(projectKey: projectKey, dio: Dio());

  // We define our `DetaBase`, with witch we are going to work from the name.
  // In case `DetaBase`  not exist it will be created instantly on first use,
  // you can create as many `DetaBase` as you need.
  final detabase = deta.base('lenguages');

  // Save an item. It will update an item if the key already exists.
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

  // Saves a list the elements, this list can only have a maximum of 20 element.
  await detabase.putMany(
    items: lenguages.map((lenguage) => lenguage.toJson()).toList(),
  );

  // Saves an element like `put`, with the difference that if this element
  // exists in `DetaBase` it will throw an `DetaObjectException`. The `key`
  // required that are part of the elemet to be saved.
  await detabase.insert({
    'key': 'r-f',
    'name': 'R',
    'description': 'R is a programming language and software environment '
        'for statistical computing and graphics.',
    'creator': 'R Foundation',
    'year': 1995,
  });

  // Update the element from the supplied `key`, you have to pass the whole
  // element, both the updated and unchanged parameters.
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

  // Get a spesific element form the key.
  final item = await detabase.get('dart-g');

  // Delete a spesific element from the key.
  final wasDeleted = await detabase.delete('ruby');

  // Return all saved items if no `query` is specified.
  final all = await detabase.fetch();

  // Return all element that matched the indicated `query`.
  final result = await detabase.fetch(
    query: [DetaQuery('year').lessThanOrEqualTo(2000).and('name').prefix('C')],
  );
}

@immutable
class Lenguage {
  const Lenguage({
    required this.key,
    required this.name,
    required this.description,
    required this.creator,
    required this.year,
  });

  factory Lenguage.fromJson(Map<String, dynamic> json) => Lenguage(
        key: json['key'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        creator: json['creator'] as String,
        year: json['year'] as int,
      );

  final String key;
  final String name;
  final String description;
  final String creator;
  final int year;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'name': name,
        'description': description,
        'creator': creator,
        'year': year,
      };

  @override
  String toString() =>
      'ProgramingLenguage(key: $key, name: $name, description: $description, '
      'creator: $creator, year: $year)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Lenguage &&
        other.key == key &&
        other.name == name &&
        other.creator == creator &&
        other.description == description &&
        other.year == year;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      name.hashCode ^
      description.hashCode ^
      creator.hashCode ^
      year.hashCode;
}

const lenguages = [
  Lenguage(
    key: 'kotlin-jb',
    name: 'Kotlin',
    description: 'Kotlin is a general-purpose, statically typed, '
        'compiled programming language that is type-safe, invariant, '
        'and flexible.',
    creator: 'JetBrains',
    year: 2011,
  ),
  Lenguage(
    key: 'swift-a',
    name: 'Swift',
    description: 'Swift is a general-purpose, multi-paradigm, '
        'safe, modern, compiled programming language running on '
        "Apple's iOS, OS X, and watchOS operating systems.",
    creator: 'Apple',
    year: 2014,
  ),
  Lenguage(
    key: 'java-o',
    name: 'Java',
    description: 'Java is a general-purpose, concurrent, class-based, '
        'object-oriented programming language that is specifically '
        'designed to have as few implementation dependencies as possible.',
    creator: 'Oracle',
    year: 1995,
  ),
  Lenguage(
    key: 'c#-m',
    name: 'C#',
    description: 'C# is a multi-paradigm programming language '
        'encompassing both object-oriented (class-based) and imperative '
        '(structured) programming styles.',
    creator: 'Microsoft',
    year: 2000,
  ),
  Lenguage(
    key: 'c++-b',
    name: 'C++',
    description: 'C++ is a general-purpose programming language '
        'and a multi-paradigm, generic, object-oriented, component-based, '
        'and reusable programming language.',
    creator: 'Borland',
    year: 1983,
  ),
  Lenguage(
    key: 'js-m',
    name: 'JavaScript',
    description: 'JavaScript is a high-level, dynamic, untyped, '
        'event-based, and prototype-based scripting language.',
    creator: 'Mozilla',
    year: 1995,
  ),
  Lenguage(
    key: 'php-rl',
    name: 'PHP',
    description: 'PHP is a server-side scripting language designed '
        'for web development but also used as a general-purpose '
        'general-purpose programming language.',
    creator: 'Rasmus Lerdorf',
    year: 1995,
  ),
  Lenguage(
    key: 'python-gvr',
    name: 'Python',
    description: 'Python is a widely used high-level, general-purpose, '
        'and interpreted programming language. Its design philosophy '
        'aims to make it easy to read and write code, to get '
        'reslts quickly, and to avoid common pitfalls.',
    creator: 'Guido van Rossum',
    year: 1991,
  ),
  Lenguage(
    key: 'ruby-ym',
    name: 'Ruby',
    description: 'Ruby is a dynamic, open source, general-purpose '
        'programming language with a focus on simplicity and productivity.',
    creator: 'Yukihir Matsumoto',
    year: 1995,
  ),
  Lenguage(
    key: 'scala-mo',
    name: 'Scala',
    description: 'Scala is a general-purpose programming language '
        'designed to make writing functional and concise.',
    creator: 'Martin dersky',
    year: 2003,
  ),
  Lenguage(
    key: 'go-g',
    name: 'Go',
    description: 'Go is an open source programming language that '
        'conforms to the Common Language Infrastructure (CLI) '
        'standard.',
    creator: 'Google',
    year: 2009,
  ),
  Lenguage(
    key: 'rust-gh',
    name: 'Rust',
    description: 'Rust is a systems programming language that '
        'conforms to the Common Language Infrastructure (CLI) '
        'standard.',
    creator: 'Graydon Hoare',
    year: 2009,
  ),
  Lenguage(
    key: 'c-dr',
    name: 'C',
    description: 'C is a general-purpose, imperative computer '
        'programming language, supporting structured programming, '
        'lexical variable scope, and recursion.',
    creator: 'Dennis Ritchie',
    year: 1972,
  )
];

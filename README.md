An in-memory fuzzy text search library for Dart.

[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:text_search/text_search.dart';

main() {
  final searchableItems = [
    TextSearchItem.fromTerms('Coffee Shop', ['coffee', 'latte', 'macchiato', 'tea']),
    TextSearchItem.fromTerms('Dessert', ['ice cream', 'cake', 'pastry']),
    TextSearchItem.fromTerms('Milk Tea Shop', ['boba', 'milk tea', 'bubble tea']),
  ];

  final placeTypeSearch = TextSearch(searchableItems);
  print(placeTypeSearch.search('icecream'));
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/FlutterFlow/text_search/issues

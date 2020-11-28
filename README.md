An in-memory fuzzy text search library for Dart.

[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:text_search/text_search.dart';

main() {
  final searchableItems = [
    TextSearchItem('Coffee Shop', ['coffee', 'latte', 'macchiato', 'tea']),
    TextSearchItem('Dessert', ['ice cream', 'cake', 'pastry']),
    TextSearchItem('Milk Tea Shop', ['boba', 'milk tea', 'bubble tea']),
  ];

  final placeTypeSearch = TextSearch(searchableItems);
  print(placeTypeSearch.search('icecream'));
  // [TextSearchResult(Dessert, 0.20740740740740726)]
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/FlutterFlow/text_search/issues

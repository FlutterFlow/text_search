import 'package:text_search/text_search.dart';

final searchableItems = [
  TextSearchItem('Coffee Shop', ['coffee', 'latte', 'macchiato', 'tea']),
  TextSearchItem('Dessert', ['ice cream', 'cake', 'pastry']),
  TextSearchItem('Milk Tea Shop', ['boba', 'milk tea', 'bubble tea']),
];
final placeTypeSearch = TextSearch(searchableItems);
void main() {
  print(placeTypeSearch.search('icecream'));
  // [TextSearchResult(Dessert, 0.20740740740740726)]
}

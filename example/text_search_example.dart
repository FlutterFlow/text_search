import 'package:text_search/text_search.dart';

final searchableItems = [
  TextSearchItem.fromTerms(
      'Coffee Shop', ['coffee', 'latte', 'macchiato', 'tea']),
  TextSearchItem.fromTerms('Dessert', ['ice cream', 'cake', 'pastry']),
  TextSearchItem.fromTerms('Milk Tea Shop', ['boba', 'milk tea', 'bubble tea']),
];
final placeTypeSearch = TextSearch(searchableItems);
void main() {
  print(placeTypeSearch.search('icecream'));
}

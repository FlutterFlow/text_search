import 'package:test/test.dart';
import 'package:text_search/text_search.dart';

void main() {
  group('TextSearch', () {
    // Sample search items
    var coffeeShop = TextSearchItem.fromTerms(
        'Coffee Shop', ['coffee', 'latte', 'espresso']);
    var teaHouse =
        TextSearchItem.fromTerms('Tea House', ['tea', 'chai', 'matcha']);
    var teaShop =
        TextSearchItem.fromTerms('Tea Shop', ['tea', 'chai', 'matcha']);
    var library =
        TextSearchItem.fromTerms('Library', ['library', 'books', 'reading']);
    var items = [coffeeShop, teaHouse, teaShop, library];
    var search = TextSearch(items);

    test('exact match returns a score of 0', () {
      var results = search.search('coffee');
      expect(results.length, greaterThan(0));
      expect(results[0].score, 0.0);
      expect(results[0].object, 'Coffee Shop');
    });

    test('fuzzy match', () {
      var results = search.search('cofee');
      expect(results.length, greaterThan(0));
      expect(results[0].object, 'Coffee Shop');
    });

    test('fastSearch returns items without scores', () {
      var results = search.fastSearch('coffe');
      expect(results, contains('Coffee Shop'));
      expect(results.length, 1);
    });

    test('search with no matches due to threshold', () {
      var results = search.search('coff', matchThreshold: 0.2);
      expect(results, isEmpty);
    });

    test('fastSearch with no matches due to threshold', () {
      var results = search.fastSearch('coff', matchThreshold: 0.2);
      expect(results, isEmpty);
    });

    test('non-matching term returns empty list', () {
      var results = search.search('zxcvbnm');
      expect(results, isEmpty);
    });

    test('items returned are sorted by increasing score', () {
      var results = search.search('tea');
      expect(results.length, greaterThan(1));
      for (var i = 0; i < results.length - 1; i++) {
        expect(results[i].score, lessThanOrEqualTo(results[i + 1].score));
      }
    });

    test('regression test for fuzzy match', () {
      final search = TextSearch([
        TextSearchItem.fromTerms('FAB', ['FloatingActionButton']),
      ]);
      expect(search.search('flo').length, 1);
      expect(search.search('floating action').length, 1);
      expect(search.search('flating').length, 1);
    });

    test('test matching with spaces', () {
      final search = TextSearch([
        TextSearchItem.fromTerms('FAB', ['floating action button']),
      ]);
      expect(search.search('floatingaction').length, 1);
      expect(search.search('floating action').length, 1);
      expect(search.search('flating').length, 1);
    });

    test('test edge cases', () {
      final search = TextSearch([
        TextSearchItem.fromTerms('single letter term', ['f']),
      ]);
      expect(search.search('f').length, 1);
      expect(search.search('floating').length, 1);
      expect(search.search('test').length, 0);
    });
  });
}

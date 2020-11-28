import 'dart:math' as math;

import 'package:edit_distance/edit_distance.dart';
import 'package:tuple/tuple.dart';

/// Represents a single item that can be searched for. The `terms` are all
/// variants that match the item. For e.g. an item `PlaceType.coffee_shop`
/// could have terms: 'coffee', 'latte', etc.
class TextSearchItem<T> {
  final T object;
  final List<String> terms;

  const TextSearchItem(this.object, this.terms);
}

/// A search result containing the matching `object` along with the `score`.
class TextSearchResult<T> {
  final T object;
  final double score;

  TextSearchResult(this.object, this.score);

  @override
  String toString() => 'TextSearchResult($object, $score)';
}

/// Used for doing simple in-memory text searching based on a given set of
/// `TextSearchItem`s. Lower scores are better, with exact case-insensitive
/// matches scoring 0. Uses `JaroWinkler` distance.
class TextSearch<T> {
  TextSearch(this.items);
  static final _editDistance = JaroWinkler();

  final List<TextSearchItem<T>> items;

  /// Returns search results along with score ordered by decreasing score.
  /// For libraries with 10k+ items, `fastSearch` will start being noticeably
  /// faster.
  List<TextSearchResult<T>> search(String term, {double matchThreshold = 1.0}) {
    return items
        .map((item) => Tuple2(
            item,
            item.terms
                .map((itemTerm) => _scoreTerm(term, itemTerm))
                .reduce(math.min)))
        .where((t) => t.item2 < matchThreshold)
        .map((t) => TextSearchResult(t.item1.object, t.item2))
        .toList()
          ..sort((a, b) => a.score.compareTo(b.score));
  }

  /// Returns search results ordered by decreasing score.
  /// ~3-5x faster than `search`, but does not include the search score.
  List<T> fastSearch(String term, {double matchThreshold = 1.0}) {
    final sorted = items
        .map((item) => Tuple2(
            item,
            item.terms
                .map((itemTerm) => _scoreTerm(term, itemTerm))
                .reduce(math.min)))
        .toList()
          ..sort((a, b) => a.item2.compareTo(b.item2));
    final result = <T>[];
    for (final candidate in sorted) {
      if (candidate.item2 >= matchThreshold) {
        break;
      }
      result.add(candidate.item1.object);
    }
    return result;
  }

  double _scoreTerm(String searchTerm, String itemTerm) {
    searchTerm = searchTerm.toLowerCase();
    itemTerm = itemTerm.toLowerCase();
    if (searchTerm == itemTerm) {
      return 0;
    }
    return _editDistance.normalizedDistance(
            searchTerm.toLowerCase(), itemTerm.toLowerCase()) *
        searchTerm.length;
  }
}

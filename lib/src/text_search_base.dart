import 'dart:math' as math;

import 'package:text_search/src/jaro_winkler.dart';
import 'package:tuple/tuple.dart';

/// Represents a candidate `term` for a search result.
class TextSearchItemTerm {
  const TextSearchItemTerm(this.term, [this.scorePenalty = 0.0]);

  final String term;
  final double scorePenalty;

  @override
  String toString() {
    return 'TextSearchItemTerm($term, $scorePenalty)';
  }
}

/// Represents a single item that can be searched for. The `terms` are all
/// variants that match the item. For e.g. an item `PlaceType.coffee_shop`
/// could have terms: 'coffee', 'latte', etc.
class TextSearchItem<T> {
  final T object;
  final Iterable<TextSearchItemTerm> terms;

  const TextSearchItem(this.object, this.terms);
  factory TextSearchItem.fromTerms(T object, Iterable<String> terms) =>
      TextSearchItem(object, terms.map((x) => TextSearchItemTerm(x)));
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
  List<TextSearchResult<T>> search(String term, {double matchThreshold = 1.5}) {
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
  List<T> fastSearch(String term, {double matchThreshold = 1.5}) {
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

  double _scoreTerm(String searchTerm, TextSearchItemTerm itemTerm) {
    if (itemTerm.term.length == 1) {
      return searchTerm.startsWith(itemTerm.term)
          ? 0 + itemTerm.scorePenalty
          : 4;
    }
    searchTerm = searchTerm.toLowerCase();
    final term = itemTerm.term.toLowerCase();
    if (searchTerm == term) {
      return 0 + itemTerm.scorePenalty;
    }
    // Direct comparison (regardless of word or sentence).
    final initialScore =
        _editDistance.distance(searchTerm.toLowerCase(), term.toLowerCase()) *
            searchTerm.length;
    if (!term.contains(' ')) {
      return initialScore + itemTerm.scorePenalty;
    }
    if (term.startsWith(searchTerm)) {
      return math.max(0.05, (0.5 - searchTerm.length / term.length)) +
          itemTerm.scorePenalty;
    }
    if (term.contains(searchTerm)) {
      return math.max(0.05, (0.7 - searchTerm.length / term.length)) +
          itemTerm.scorePenalty;
    }
    // Compare to sentences by splitting to each component word.
    final words = term.split(' ');
    final perWordScore = words
        .where((word) => word.length > 1)
        .map(
          (word) =>
              // Penalize longer sentences and avoid multiply by 0 (exact match).
              math.sqrt(words.length + 1) *
              (0.1 +
                  _scoreTerm(searchTerm,
                      TextSearchItemTerm(word, itemTerm.scorePenalty))),
        )
        .reduce(math.min);
    final scoreWithoutEmptySpaces = _scoreTerm(
      searchTerm.replaceAll(' ', ''),
      TextSearchItemTerm(term.replaceAll(' ', ''), itemTerm.scorePenalty),
    );
    return math.min(
            scoreWithoutEmptySpaces, math.min(initialScore, perWordScore)) +
        itemTerm.scorePenalty;
  }
}

import 'dart:math';

class JaroWinkler {
  final double _scalingFactor;

  JaroWinkler([this._scalingFactor = 0.1]);

  double similarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) {
      return 0.0;
    }
    if (s1 == s2) {
      return 1.0;
    }

    var matchDistance = (s1.length / 2).ceil() - 1;
    var s1Matches = List<bool>.filled(s1.length, false);
    var s2Matches = List<bool>.filled(s2.length, false);

    var matches = 0;
    var transpositions = 0;

    for (var i = 0; i < s1.length; i++) {
      int start = max(0, i - matchDistance);
      int end = min(s2.length - 1, i + matchDistance);

      for (var j = start; j <= end; j++) {
        if (s2Matches[j]) continue;

        if (s1[i] != s2[j]) continue;

        s1Matches[i] = true;
        s2Matches[j] = true;

        matches++;
        break;
      }
    }

    if (matches == 0) return 0.0;

    var k = 0;
    for (var i = 0; i < s1.length; i++) {
      if (!s1Matches[i]) continue;

      while (!s2Matches[k]) {
        k++;
      }

      if (s1[i] != s2[k]) transpositions++;

      k++;
    }

    var jaro = ((matches / s1.length) +
            (matches / s2.length) +
            ((matches - transpositions / 2) / matches)) /
        3.0;

    var prefix = 0;
    for (var i = 0; i < min(4, s1.length); i++) {
      if (s1[i] == s2[i]) {
        prefix++;
      } else {
        break;
      }
    }

    return jaro + (prefix * _scalingFactor * (1 - jaro));
  }

  double distance(String s1, String s2) {
    return 1 - similarity(s1, s2);
  }
}

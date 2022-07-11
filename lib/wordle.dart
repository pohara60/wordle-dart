/// An API for finding and scoring legal Wordle words.
///
/// The legal words are defined in the SOWPODS dictionary (see
/// https://en.wikipedia.org/wiki/Collins_Wordle_Words).
library wordle;

import './src/buffer.dart';
//import './Wordle_builder.dart';

// Part file has compressed dictionary buffer
part 'nytimes-wordle.dart';

/// Provide access to the Wordle API.
class Wordle {
  // static const _dictionaryFile = 'lib/sowpods.txt';
  static final _dictionary = <String>{};

  static const List<String> _alphabet = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z'
  ];

  Wordle() {
    _initWordle();
  }

  void _initWordle() {
    if (_dictionary.isNotEmpty) return;

    //final stopwatch = Stopwatch()..start();
    // Read dictionary from buffer
    var readBuffer = Buffer(_lookupCharacters, _lookupCharacters2, null,
        _wordCharacters, _prefixCharacters, _specialCharacters);
    readBuffer.setCompressedBuffer(_buffer);
    String entry;
    while ((entry = readBuffer.readEntry()) != '') {
      _dictionary.add(entry);
    }
    // print('dictionary loaded in ${stopwatch.elapsed}');
  }

  /// **lookup** legal words, perhaps includng the wildcard '?'.
  ///
  Set<String> lookup(String word, {bool expand = false}) {
    var matches = _lookup('', word);
    if (matches.isNotEmpty) {
      if (!expand) {
        return {word};
      } else {
        return matches;
      }
    }
    return {};
  }

  Set<String> _lookup(String start, String rest) {
    // print('start=$start');
    // print('rest=$rest');
    var index = rest.indexOf('?');
    // print('index=$index');
    if (index == -1) {
      var word = start + rest;
      if (_dictionary.contains(word)) {
        // print('dictionaryLookup: dictionary contains $word');
        return {word};
      }
      return {};
    }

    var prefix = rest.substring(0, index);
    // print('prefix=$prefix');
    // Wildcard
    var matches = <String>{};
    for (var c in _alphabet) {
      matches.addAll(_lookup(start + prefix + c, rest.substring(index + 1)));
    }
    return matches;
  }

  void addCharsToSet(Set set, String str) {
    for (var i = 0; i < str.length; i++) {
      var c = str[i];
      if (c != '?') set.add(c);
    }
  }

  /// **solution** for correct, present and absent letters, with guesses.
  ///
  Set<String> solution(String? correct, List<String> present, String? absent,
      List<String> guesses) {
    var correctStr = correct ?? '?????';
    var absentStr = absent ?? '?????';
    var invalid = <String>{};
    var allChar = <String>{};
    addCharsToSet(allChar, correctStr);
    for (var presentStr in present) {
      addCharsToSet(allChar, presentStr);
    }
    addCharsToSet(invalid, absentStr);
    for (var g in guesses) {
      for (var i = 0; i < g.length; i++) {
        var c = g[i];
        if (!allChar.contains(c)) invalid.add(c);
      }
    }
    var matches = _solution('', correctStr, present, invalid);
    return matches;
  }

  Set<String> _solution(
      String start, String rest, List<String> present, Set<String> invalid,
      [String presentStr = '']) {
    var index = rest.indexOf('?');
    if (index == -1) {
      var word = start + rest;
      presentStr = presentStr.padRight(word.length, '?');
      if (_dictionary.contains(word)) {
        // Check that the present characters appear in non-fixed positions
        for (var m in present) {
          var checkStr = presentStr;
          for (var i = 0; i < m.length; i++) {
            var c = m[i];
            if (c != '?') {
              if (!checkStr.contains(c)) {
                return {};
              }
              checkStr = checkStr.replaceFirst(c, '?');
            }
          }
        }
        return {word};
      }
      return {};
    }

    // Wildcard
    var prefix = start + rest.substring(0, index);
    presentStr = presentStr.padRight(prefix.length, '?');
    var matches = <String>{};
    var charIndex = start.length + index;
    for (var c in _alphabet.where((c) =>
        !invalid.contains(c) &&
        !present.any((str) => str.length > charIndex && str[charIndex] == c))) {
      matches.addAll(_solution(prefix + c, rest.substring(index + 1), present,
          invalid, presentStr + c));
    }
    return matches;
  }
}

/// An API for finding and scoring legal Wordle words.
///
/// The legal words are defined in the SOWPODS dictionary (see
/// https://en.wikipedia.org/wiki/Collins_Wordle_Words).
library wordle;

import 'dart:collection';

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

  static const String WordleLetters =
      'aaaaaaaaabbccddddeeeeeeeeeeeeffggghhiiiiiiiiijkllllmmnnnnnnooooooooppqrrrrrrssssttttttuuuuvvwwxyyz??';

  static const Map<String, int> WordleValues = {
    'a': 1,
    'e': 1,
    'i': 1,
    'l': 1,
    'n': 1,
    'o': 1,
    'r': 1,
    's': 1,
    't': 1,
    'u': 1,
    'd': 2,
    'g': 2,
    'b': 3,
    'c': 3,
    'm': 3,
    'p': 3,
    'f': 4,
    'h': 4,
    'v': 4,
    'w': 4,
    'y': 4,
    'k': 5,
    'j': 8,
    'x': 8,
    'q': 10,
    'z': 10,
    '?': 0
  };

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
  /// If [expand] is true then wildcards are expanded.
  Set<String> lookup(String word, {bool expand = false}) {
    var matches = _dictionaryLookup('', word);
    if (matches.isNotEmpty) {
      if (!expand) {
        return {word};
      } else {
        return matches;
      }
    }
    return {};
  }

  void addCharsToSet(Set set, String str) {
    for (var i = 0; i < str.length; i++) {
      var c = str[i];
      if (c != '?') set.add(c);
    }
  }

  /// **solution** for good and bad letters, with guesses.
  ///
  Set<String> solution(String? good, List<String> maybe, List<String> guesses) {
    var goodStr = good ?? '?????';
    var invalid = <String>{};
    var allChar = <String>{};
    addCharsToSet(allChar, goodStr);
    for (var maybeStr in maybe) {
      addCharsToSet(allChar, maybeStr);
    }
    for (var g in guesses) {
      for (var i = 0; i < g.length; i++) {
        var c = g[i];
        if (!allChar.contains(c)) invalid.add(c);
      }
    }
    var matches = _dictionarySolution('', goodStr, maybe, invalid);
    return matches;
  }

  Set<String> _dictionaryLookup(String start, String rest) {
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
      matches.addAll(
          _dictionaryLookup(start + prefix + c, rest.substring(index + 1)));
    }
    return matches;
  }

  Set<String> _dictionarySolution(
      String start, String rest, List<String> maybe, Set<String> invalid,
      [String maybeStr = '']) {
    // print('start=$start');
    // print('rest=$rest');
    // print('bad=$bad');
    // print('invalid=$invalid');
    // print('maybeStr=$maybeStr');
    var index = rest.indexOf('?');
    // print('index=$index');
    if (index == -1) {
      var word = start + rest;
      maybeStr = maybeStr.padRight(word.length, '?');
      if (_dictionary.contains(word)) {
        // print('dictionarySolution: dictionary contains $word');
        // Check that the maybe characters appear in non-fixed positions
        for (var m in maybe) {
          var checkStr = maybeStr;
          for (var i = 0; i < m.length; i++) {
            var c = m[i];
            if (c != '?') {
              if (!checkStr.contains(c)) return {};
              checkStr = checkStr.replaceFirst(c, '?');
            }
          }
        }
        return {word};
      }
      return {};
    }

    var prefix = start + rest.substring(0, index);
    maybeStr = maybeStr.padRight(prefix.length, '?');
    // print('prefix=$prefix');
    // Wildcard
    var matches = <String>{};
    var charIndex = start.length + index;
    for (var c in _alphabet.where((c) =>
        !invalid.contains(c) &&
        !maybe.any((str) => str.length > charIndex && str[charIndex] == c))) {
      matches.addAll(_dictionarySolution(
          prefix + c, rest.substring(index + 1), maybe, invalid, maybeStr + c));
    }
    return matches;
  }
}

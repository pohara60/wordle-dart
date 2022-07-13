/// An API for finding and scoring legal Wordle words.
///
library wordle;

import 'dart:math';

import './src/buffer.dart';
import 'affine.dart';

// Part file has compressed Wordle dictionary buffer
part 'nytimes-wordle.dart';

// Part file has compressed guess dictionary buffer
part 'nytimes-guess.dart';

/// Score for a letter in a guess
enum WordleScore { ABSENT, PRESENT, CORRECT }

/// Provide access to the Wordle API.
class Wordle {
  static final _wordleDictionary = <String>{};
  static final _guessDictionary = <String>{};

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

  late Affine affine;

  Wordle() {
    _initWordle();
    affine = Affine(5, 8);
  }

  void _initWordle() {
    if (_wordleDictionary.isNotEmpty) return;

    //final stopwatch = Stopwatch()..start();
    // Read wordle dictionary from buffer
    var readBuffer = Buffer(_lookupCharacters_1, _lookupCharacters2_1, null,
        _wordCharacters_1, _prefixCharacters_1, _specialCharacters_1);
    readBuffer.setCompressedBuffer(_buffer_1);
    String entry;
    while ((entry = readBuffer.readEntry()) != '') {
      _wordleDictionary.add(entry);
    }
    // Read guess dictionary from buffer
    readBuffer = Buffer(_lookupCharacters_2, _lookupCharacters2_2, null,
        _wordCharacters_2, _prefixCharacters_2, _specialCharacters_2);
    readBuffer.setCompressedBuffer(_buffer_2);
    while ((entry = readBuffer.readEntry()) != '') {
      _guessDictionary.add(entry);
    }
    // print('wordle has ${_wordleDictionary.length}, guess has ${_guessDictionary.length}');
    // print('dictionary loaded in ${stopwatch.elapsed}');
  }

  /// **lookupWord** looks up legal words, perhaps includng the wildcard '?'.
  ///
  Set<String> lookupWord(String word) {
    var matches = _lookup('', word);
    return matches;
  }

  Set<String> _lookup(String start, String rest) {
    var index = rest.indexOf('?');
    if (index == -1) {
      var word = start + rest;
      if (_wordleDictionary.contains(word)) {
        return {word};
      }
      return {};
    }

    // Wildcard
    var prefix = rest.substring(0, index);
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

  /// **getSolutions** specified for correct, present and absent letters, with guesses.
  ///
  /// The good argument is optional.
  /// The absent and present arguments  are alternatives - they may be computed
  /// from each other using the correct and guesses arguments.
  /// The guesses argument is optional, but is normally provided.
  Set<String> getSolutions(String? correct, List<String> present,
      String? absent, List<String> guesses) {
    var correctStr = correct ?? '?????';

    // The absent and present options are alternatives
    var invalidChars = <String>{};
    if (absent == null) {
      // Compute absent from present, correct and guesses
      var validChars = <String>{};
      addCharsToSet(validChars, correctStr);
      for (var presentStr in present) {
        addCharsToSet(validChars, presentStr);
      }
      for (var g in guesses) {
        for (var i = 0; i < g.length; i++) {
          var c = g[i];
          if (!validChars.contains(c)) invalidChars.add(c);
        }
      }
    } else {
      addCharsToSet(invalidChars, absent);
      // Compute present from absent, correct and guesses
      var newMaybe = <String>[];
      var oldMaybe = List.from(present);
      for (var g in guesses) {
        // Remove correct and absent characters from guess to give present
        var m = '';
        var rest = '';
        for (var i = 0; i < g.length; i++) {
          var c = g[i];
          if (correctStr[i] == c) {
            rest += '?';
            m += '?';
          } else if (absent.contains(c)) {
            rest += correctStr[i];
            m += '?';
          } else {
            rest += correctStr[i];
            m += c;
          }
        }
        // Remove present characters that appear in remaining correct
        for (var i = 0; i < m.length; i++) {
          var c = m[i];
          if (c != '?' && rest.contains(c)) {
            // Character in correct, so consume it
            rest = rest.replaceFirst(c, '?');
            m = m.replaceFirst(c, '?', i);
          } else if (c != '?' && m.contains(c, i + 1)) {
            // Character is duplicated in present, so remove this one
            m = m.replaceFirst(c, '?', i);
          }
        }
        if (m != '?????') {
          if (!newMaybe.contains(m)) {
            newMaybe.add(m);
            if (oldMaybe.isNotEmpty && !oldMaybe.remove(m)) {
              // print('Inconsistent options, missing -m $m');
            }
          }
        }
      }
      if (oldMaybe.isNotEmpty) {
        // print('Inconsistent options, missing -m $oldMaybe');
      }
      present = newMaybe;
    }

    // Get solutions
    var matches = _solution('', correctStr, present, invalidChars);
    return matches;
  }

  Set<String> _solution(
      String start, String rest, List<String> present, Set<String> invalidChars,
      [String presentStr = '']) {
    var index = rest.indexOf('?');
    if (index == -1) {
      var word = start + rest;
      presentStr = presentStr.padRight(word.length, '?');
      if (_wordleDictionary.contains(word)) {
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
        !invalidChars.contains(c) &&
        !present.any((str) => str.length > charIndex && str[charIndex] == c))) {
      matches.addAll(_solution(prefix + c, rest.substring(index + 1), present,
          invalidChars, presentStr + c));
    }
    return matches;
  }

  /// **getSecret** gets a secret (encrypted) word to start a game.
  ///
  /// Words come from the small (2K) list of legal NY Times words.
  String getSecret() {
    var word =
        _wordleDictionary.elementAt(Random().nextInt(_wordleDictionary.length));
    var secret = affine.encrypt(word);
    return secret;
  }

  /// **getScore** gets the score for guess of secret.
  ///
  /// The secret must have been obtained using **getSecret**.
  /// The guess must be a valid word, in the longer (13K) list of legal NY Times guesses.
  List<WordleScore> getScore(String secret, String guess) {
    // Do not score illegal guesses
    if (!_guessDictionary.contains(guess)) {
      return [];
    }
    var scoreCorrect = <WordleScore>[];
    var word = affine.decrypt(secret);
    for (var i = 0; i < guess.length; i++) {
      var s = WordleScore.ABSENT;
      var g = guess[i];
      if (g == word[i]) {
        s = WordleScore.CORRECT;
        // Consume correct letters
        word = word.replaceFirst(g, '?', i);
      }
      scoreCorrect.add(s);
    }
    var scorePresent = <WordleScore>[];
    for (var i = 0; i < guess.length; i++) {
      if (scoreCorrect[i] == WordleScore.CORRECT) {
        scorePresent.add(WordleScore.CORRECT);
      } else {
        var g = guess[i];
        var index = word.indexOf(g);
        if (index != -1) {
          scorePresent.add(WordleScore.PRESENT);
          // Consume present letters
          word = word.replaceFirst(g, '?', index);
        } else {
          scorePresent.add(WordleScore.ABSENT);
        }
      }
    }
    return scorePresent;
  }
}

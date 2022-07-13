import 'package:wordle/wordle.dart';

void main(List<String> args) {
  final wordle = Wordle();
  // Lookup arguments
  for (var word in args) {
    var matches = wordle.lookupWord(word);
    printMatches(wordle, 'Lookup', word, matches);
  }

  // A fixed Solution example
  var matches = wordle.getSolutions('?a??y', [], 'conetrilhrfxqukbd',
      ['cones', 'trial', 'other', 'feral', 'relax', 'relay', 'quirk', 'baddy']);
  printMatches(
      wordle,
      'Solution',
      '-c ?a??y -a conetrilhrfxqukbd cones trial other feral relax relay quirk baddy',
      matches);

  // Score milky
  printScores(wordle, 'GetScore', 'hilly', wordle.getScore('qwlgy', 'hilly'));

  // Score briar
  for (var guess in ['trial', 'flair', 'rainy', 'arise', 'briar']) {
    var scores = wordle.getScore('npwip', guess);
    printScores(wordle, 'GetScore', guess, scores);
  }
}

// Print matches with scores
void printMatches(
    Wordle wordle, String command, String word, Set<String> matches) {
  print('$command $word = $matches');
}

void printScores(
    Wordle wordle, String command, String guess, List<WordleScore> scores) {
  var score = scores.fold<String>(
      '',
      (value, element) =>
          value +
          (element == WordleScore.ABSENT
              ? 'A'
              : (element == WordleScore.PRESENT ? 'P' : 'C')));
  print('$command $guess = $score');
}

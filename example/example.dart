import 'package:wordle/wordle.dart';

void main(List<String> args) {
  final wordle = Wordle();
  // Lookup arguments
  for (var word in args) {
    var matches = wordle.lookup(word);
    printMatches(wordle, 'Lookup', word, matches);
  }

  // A fixed Solution example
  var matches = wordle.solution('?a??y', [], 'conetrilhrfxqukbd',
      ['cones', 'trial', 'other', 'feral', 'relax', 'relay', 'quirk', 'baddy']);
  printMatches(
      wordle,
      'Solution',
      '-c ?a??y -a conetrilhrfxqukbd cones trial other feral relax relay quirk baddy',
      matches);
}

// Print matches with scores
void printMatches(
    Wordle wordle, String command, String word, Set<String> matches) {
  print('$command $word = $matches');
}

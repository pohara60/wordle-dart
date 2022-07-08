import 'package:wordle/wordle.dart';

void main(List<String> args) {
  final wordle = Wordle();
  // Lookup arguments
  for (var word in args) {
    var matches = wordle.lookup(word, expand: true);
    printMatches(wordle, 'Lookup', word, matches);
  }
}

// Print matches with scores
void printMatches(
    Wordle wordle, String command, String word, Set<String> matches) {
  print('$command $word $matches');
  for (var match in matches) {
    print('Score $match = ${wordle.score(match)}');
  }
}

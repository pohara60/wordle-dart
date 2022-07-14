# Wordle Library for Dart

## Introduction

**Wordle** provides an API and command line tool for finding Wordle solutions defined in the NYTimes Wordle dictionary (see
https://static.nytimes.com/newsgraphics/2022/01/25/wordle-solver/assets/solutions.txt).

-   The API includes methods to:
    -   **getSecret** gets a secret (encrypted) word to start a game.
        Words come from the small (2K) list of legal NY Times words.
    -   **getScore** gets the score for guess of secret.
        The secret must have been obtained using **getSecret**.
        The guess must be a valid word, in the longer (13K) list of legal NY Times guesses.
    -   **lookupWord** looks up legal words, perhaps includng the wildcard '?'.
    -   **getSolutions** for specified correct, present and absent letters, with guesses.
        The good argument is optional.
        The absent and present arguments are alternatives - they may be computed
        from each other using the correct and guesses arguments.
        The guesses argument is optional, but is normally provided.
-   The command line tool provides access to the API from the command line.

## Installing Wordle

1. Depend on it

    Add this to your package's pubspec.yaml file:

    ```
    dependencies:
      wordle: ^1.0.0
    ```

2. Install it

    You can install packages from the command line:

    ```bash
    $ dart pub get
    ```

3. Import it

    Now in your Dart code, you can use:

    ```dart
    import 'package:wordle/wordle.dart';
    ```

4. Install Command Line tool

    Activate the command:

    ```bash
    $ dart pub global activate wordle
    ```

    If this doesn’t work, you might need to [set up your path](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path).

## Examples

### Command Line Example

The command line tool has many options as described in the help text, run:

```bash
$ dart run wordle --help
...
```

### Dart Example

See `example/example.dart`

```dart
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
```

Run the example with one or more sets of letters:

```bash
dart run ./example/example.dart "whin?"
Lookup whin? = {whine, whiny}
Solution -c ?a??y -a conetrilhrfxqukbd cones trial other feral relax relay quirk baddy = {gassy, sappy, sassy, savvy}
GetScore hilly = ACCAC
GetScore trial = ACCCA
GetScore flair = AAPPC
GetScore rainy = PPCAA
GetScore arise = PCCAA
```

### Web Example

See `example/web/web.dart`.

This is a version of the wordle game using the wordle package.

Run the example as follows:

```bash
$ cd example
$ webdev serve web
[INFO] Reading cached asset graph completed, took 198ms
[INFO] Checking for updates since last build completed, took 618ms
[INFO] Serving `web` on http://127.0.0.1:8080
[INFO] Running build completed, took 1.6s
[INFO] Caching finalized dependency graph completed, took 114ms
[INFO] Succeeded after 1.8s with 15 outputs (12 actions)
[INFO] ------------------------------------------------------------------------------------
```

Then open the page `http://127.0.0.1:8080`.

## Package Development

This documentation is not needed to use the package, just for its development.

The package converts the two cleartext dictionary files (lib/nytimes-wordle.txt and nytimes-guess.txt)
into compressed string buffers at package development time, using the Dart
**build_runner** package and the command:

```bash
dart run build_runner build
```

This approach was adopted to provide web client-side access to the dictionary.

(Actually it was copied from my scrabble package, which has a much larger dictionary. It is overkill
for these much smaller dictionaries!)

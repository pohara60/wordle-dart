# Wordle Library for Dart

## TODO

1. Update README!
2. Add GetSolutions
3. Improve HTML

## Introduction

**Wordle** provides an API and command line tool for finding Wordle solutions defined in the NYTimes Wordle dictionary (see
https://static.nytimes.com/newsgraphics/2022/01/25/wordle-solver/assets/solutions.txt).

-   The API includes methods to:
    -   **lookup** legal words, perhaps includng the wildcard '?'.
-   The command line tool provides access to the API from the command line.

## Installing Wordle

1. Depend on it

    Add this to your package's pubspec.yaml file:

    ```
    dependencies:
      wordle: ^0.1.0
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

This example does a lookup for three letter words including 'a', 'b' and the wildcard '?'.

```bash
$ dart run wordle lookup --expand ab?
Lookup ab? {aba, abb, abo, abs, aby}
Score aba = 5
Score abb = 7
Score abo = 5
Score abs = 5
Score aby = 8
```

### Dart Example

See `example/example.dart`

```dart
import 'package:wordle/wordle.dart';

void main(List<String> args) {
  final wordle = wordle();
  // Lookup arguments
  for (var word in args) {
    var matches = wordle.lookup(word, expand: true);
    printMatches(wordle, 'Lookup', word, matches);
  }
  // Get anagrams of arguments
  for (var word in args) {
    var matches = wordle.anagram(word, expand: true, sort: true);
    printMatches(wordle, 'Anagram', word, matches);
  }
}

// Print matches with scores
void printMatches(
    wordle wordle, String command, String word, Set<String> matches) {
  print('$command $word $matches');
  for (var match in matches) {
    print('Score $match = ${wordle.score(match)}');
  }
}
```

Run the example with one or more sets of letters:

```bash
$ cd example
$ dart run example.dart abc
Lookup abc {}
Anagram abc {ab, ba, bac, cab}
Score ab = 4
Score ba = 4
Score bac = 7
Score cab = 7
$
```

### Web Example

See `example/web/web.dart`.

This is a version of the wordle example at https://dart.dev/tutorials/web/low-level-html/add-elements#moving-elements,
modified to use the wordle package.

Run the example as follows:

```bash
$ cd example
$ webdev serve web
[INFO] There was output on stdout while compiling the build script snapshot, run with `--verbose` to see it (you will ne[WARNING] Throwing away cached asset graph because the build phases have changed. This most commonly would happen as a result of adding a new dependency or updating your dependencies.
[WARNING] Throwing away cached asset graph because the language version of some package(s) changed. This would most commonly happen when updating dependencies or changing your min sdk constraint.
[INFO] Cleaning up outputs from previous builds. completed, took 614ms
[INFO] There was output on stdout while compiling the build script snapshot, run with `--verbose` to see it (you will ne[INFO] Building new asset graph completed, took 2.7s
[INFO] Checking for unexpected pre-existing outputs. completed, took 5ms
[INFO] Serving `web` on http://127.0.0.1:8080
[INFO] Generating SDK summary completed, took 8.2s
[WARNING] No actions completed for 15.0s, waiting on:
  - build_web_compilers:sdk_js on asset:build_web_compilers/$package$
  - build_web_compilers:entrypoint on web/web.dart

[INFO] Running build completed, took 42.4s
[INFO] Caching finalized dependency graph completed, took 305ms
[INFO] Succeeded after 42.7s with 879 outputs (2958 actions)
[INFO] ----------------------------------------------------------------------------------------------------------------
[INFO] Injected debugging metadata for entrypoint at http://localhost:8080/web.dart.bootstrap.js
```

Then open the page `http://127.0.0.1:8080`.

## Package Development

This documentation is not needed to use the package, just for its development.

The package converts the cleartext dictionary file (lib/nytimes-wordle.txt) into a
compressed string buffer at package development time, using the Dart
**build_runner** package and the command:

```bash
dart run build_runner build
```

This approach was adopted to provide web client-side access to the dictionary.

import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:wordle/wordle.dart';

const help = 'help';
const program = 'wordle';

void main(List<String> arguments) async {
  exitCode = 0; // presume success

  var runner = CommandRunner('wordle', 'Wordle helper.')
    ..addCommand(SolutionCommand())
    ..addCommand(GetSecretCommand())
    ..addCommand(GetScoreCommand())
    ..addCommand(LookupCommand());
  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    // Arguments exception
    print('$program: ${e.message}');
    print('');
    print('${runner.usage}');
  } catch (e) {
    print('$program: $e');
  }
}

class LookupCommand extends Command {
  @override
  final name = 'lookup';
  @override
  final description = 'Lookup <arguments> in dictionary.';

  // ignore: empty_constructor_bodies
  LookupCommand();

  @override
  void run() {
    // Get and print lookup
    final wordle = Wordle();
    for (var word in argResults!.rest) {
      var matches = wordle.lookupWord(word);
      printMatches(wordle, 'Lookup', word, matches);
    }
  }
}

class SolutionCommand extends Command {
  @override
  final name = 'solution';
  @override
  final description = '''Get solutions.
  
The [arguments] are the guesses so far.
The --correct option may specify correct letters.
The --absent option may specify incorrect letters.
The --present option may specify incorrectly placed letters.
Only one of --present and --absent are required.

For example:
  wordle solution --correct ????e --absent contariu cones stare issue''';

  SolutionCommand() {
    argParser.addOption(
      'absent',
      abbr: 'a',
      help:
          'Incorrect letters, i.e. letters that cannot appear, arbitrary length.',
    );
    argParser.addOption(
      'correct',
      abbr: 'c',
      help:
          'Correctly placed letters, with ? for unknown letters, 5 letters long.',
    );
    argParser.addMultiOption(
      'present',
      abbr: 'p',
      help:
          'Incorrectly placed letters, excluding correct letters, 5 letters long. Specify multiple times for multiple positions.',
    );
  }

  @override
  void run() {
    // Validate options
    String correct = argResults!['correct'] ?? '?????';
    String? absent = argResults!['absent'];
    List<String> present = argResults!['present'];
    var guesses = argResults!.rest;
    // Get and print solutions
    final wordle = Wordle();
    var solutions = wordle.getSolution(correct, present, absent, guesses);
    var args = '-c $correct -a ${absent ?? '""'} -p $present $guesses';
    printMatches(wordle, 'Solution', args, solutions);
  }
}

void printMatches(
    Wordle wordle, String command, String word, Set<String> matches) {
  print('$command $word = $matches');
}

class GetSecretCommand extends Command {
  @override
  final name = 'getSecret';
  @override
  final description = 'GetSecret word.';

  // ignore: empty_constructor_bodies
  GetSecretCommand();

  @override
  void run() {
    // Get and print secret
    final wordle = Wordle();
    var secret = wordle.getSecret();
    print('getSecret = $secret');
  }
}

class GetScoreCommand extends Command {
  @override
  final name = 'getScore';
  @override
  final description = 'GetScore for <arguments> that guess the secret word.';

  // ignore: empty_constructor_bodies
  GetScoreCommand() {
    argParser.addOption(
      'secret',
      abbr: 's',
      mandatory: true,
      help: 'The secret word, obtained using getSecret.',
    );
  }

  @override
  void run() {
    // Get score for each argument
    String secret = argResults!['secret']!;
    print('getScore = $secret');
    final wordle = Wordle();
    for (var guess in argResults!.rest) {
      var scores = wordle.getScore(secret, guess);
      printScores(wordle, 'GetScore', guess, scores);
    }
  }
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

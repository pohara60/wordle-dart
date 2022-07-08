import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:wordle/wordle.dart';

const help = 'help';
const program = 'wordle';

void main(List<String> arguments) async {
  exitCode = 0; // presume success

  var runner = CommandRunner('wordle', 'Wordle helper.')
    ..addCommand(SolutionCommand())
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

  LookupCommand() {
    argParser.addFlag(
      'expand',
      abbr: 'e',
      negatable: false,
      help: 'Output expanded wildcards.',
    );
  }

  @override
  void run() {
    // Get and print lookup
    final wordle = Wordle();
    for (var word in argResults!.rest) {
      var matches = wordle.lookup(word, expand: argResults!['expand'] ?? false);
      printMatches(wordle, 'Lookup', word, matches);
    }
  }
}

class SolutionCommand extends Command {
  @override
  final name = 'solution';
  @override
  final description = 'Get solutions.';

  SolutionCommand() {
    argParser.addOption(
      'good',
      abbr: 'g',
      help: 'Correctly placed letters.',
    );
    argParser.addMultiOption(
      'maybe',
      abbr: 'm',
      help: 'Incorrectly placed letters.',
    );
    argParser.addMultiOption(
      'bad',
      abbr: 'b',
      help: 'Incorrect letters.',
    );
  }

  @override
  void run() {
    // Validate options
    String? good = argResults!['good'];
    String? bad = argResults!['bad'];
    List<String> maybe = argResults!['maybe'];
    // Get and print solutions
    final wordle = Wordle();
    var guesses = argResults!.rest;
    var solutions = wordle.solution(good, maybe, guesses);
    var args = '-g ${good ?? ""} -m $maybe $guesses';
    printMatches(wordle, 'Solution', args, solutions);
  }
}

void printMatches(
    Wordle wordle, String command, String word, Set<String> matches) {
  print('$command $word = $matches');
}

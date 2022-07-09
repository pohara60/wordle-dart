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
  final description = '''Get solutions.
  
The [arguments] are the guesses so far.
The --good option may specify correct letters.
The --bad option may specify incorrect letters.
The --maybe option may specify incorrectly placed letters.
Only one of --maybe and --bad are required.

For example:
  wordle solution --good ????e --bad contariu cones stare issue''';

  SolutionCommand() {
    argParser.addOption(
      'bad',
      abbr: 'b',
      help:
          'Incorrect letters, i.e. letters that cannot appear, arbitrary length.',
    );
    argParser.addOption(
      'good',
      abbr: 'g',
      help:
          'Correctly placed letters, with ? for unknown letters, 5 letters long.',
    );
    argParser.addMultiOption(
      'maybe',
      abbr: 'm',
      help:
          'Incorrectly placed letters, excluding good letters, 5 letters long. Specify multiple times for multiple positions.',
    );
  }

  @override
  void run() {
    // Validate options
    String good = argResults!['good'] ?? '?????';
    String? bad = argResults!['bad'];
    List<String> maybe = argResults!['maybe'];
    var guesses = argResults!.rest;
    // The bad and maybe options are alternatives, compute maybe from bad and guesses
    if (bad != null) {
      var newMaybe = <String>[];
      var oldMaybe = List.from(maybe);
      for (var g in guesses) {
        // Remove good and bad characters from guess to give maybe
        var m = '';
        var rest = '';
        for (var i = 0; i < g.length; i++) {
          var c = g[i];
          if (good[i] == c) {
            rest += '?';
            m += '?';
          } else if (bad.contains(c)) {
            rest += good[i];
            m += '?';
          } else {
            rest += good[i];
            m += c;
          }
        }
        // Remove maybe characters that appear in remaining good
        for (var i = 0; i < m.length; i++) {
          var c = m[i];
          if (c != '?' && rest.contains(c)) {
            // Character in good, so consume it
            rest = rest.replaceFirst(c, '?');
            m = m.replaceFirst(c, '?', i);
          } else if (c != '?' && m.contains(c, i + 1)) {
            // Character is duplicated in maybe, so remove this one
            m = m.replaceFirst(c, '?', i);
          }
        }
        if (m != '?????') {
          if (!newMaybe.contains(m)) {
            newMaybe.add(m);
            if (oldMaybe.isNotEmpty && !oldMaybe.remove(m)) {
              print('Inconsistent options, missing -m $m');
            }
          }
        }
      }
      if (oldMaybe.isNotEmpty) {
        print('Inconsistent options, missingm $oldMaybe');
      }
      maybe = newMaybe;
    }
    // Get and print solutions
    final wordle = Wordle();
    var solutions = wordle.solution(good, maybe, guesses);
    var args = '-g $good -m $maybe $guesses';
    printMatches(wordle, 'Solution', args, solutions);
  }
}

void printMatches(
    Wordle wordle, String command, String word, Set<String> matches) {
  print('$command $word = $matches');
}

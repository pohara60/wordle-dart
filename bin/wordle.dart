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

  // ignore: empty_constructor_bodies
  LookupCommand();

  @override
  void run() {
    // Get and print lookup
    final wordle = Wordle();
    for (var word in argResults!.rest) {
      var matches = wordle.lookup(word, expand: true);
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
    // The absent and present options are alternatives, compute present from absent and guesses
    // TODO support absent with no guesses
    if (absent != null) {
      var newMaybe = <String>[];
      var oldMaybe = List.from(present);
      for (var g in guesses) {
        // Remove correct and absent characters from guess to give present
        var m = '';
        var rest = '';
        for (var i = 0; i < g.length; i++) {
          var c = g[i];
          if (correct[i] == c) {
            rest += '?';
            m += '?';
          } else if (absent.contains(c)) {
            rest += correct[i];
            m += '?';
          } else {
            rest += correct[i];
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
              print('Inconsistent options, missing -m $m');
            }
          }
        }
      }
      if (oldMaybe.isNotEmpty) {
        print('Inconsistent options, missingm $oldMaybe');
      }
      present = newMaybe;
    }
    // Get and print solutions
    final wordle = Wordle();
    var solutions = wordle.solution(correct, present, absent, guesses);
    var args = '-c $correct -a ${absent ?? '""'} -p $present $guesses';
    printMatches(wordle, 'Solution', args, solutions);
  }
}

void printMatches(
    Wordle wordle, String command, String word, Set<String> matches) {
  print('$command $word = $matches');
}

import 'dart:convert';
import 'dart:io';

import 'package:wordle/wordle.dart';
import 'package:test/test.dart';

void main() {
  group('API', () {
    final wordle = Wordle();
    test('lookup whin? = {whine, whiny}', () {
      expect(wordle.lookup('whin?'), {'whine', 'whiny'});
    });
    test('lookup abcde = {}', () {
      expect(wordle.lookup('abcde'), <String>{});
    });
    test(
        'solution -c ?a??y -a conetrilhrfxqukbd = {gassy, jazzy, mammy, sappy, sassy, savvy}',
        () {
      expect(wordle.solution('?a??y', [], 'conetrilhrfxqukbd', []),
          {'gassy', 'jazzy', 'mammy', 'sappy', 'sassy', 'savvy'});
    });
    test(
        'solution -c ?a??y -a conetrilhrfxqukbd cones trial other feral relax relay quirk baddy = {gassy, sappy, sassy, savvy}',
        () {
      expect(
          wordle.solution(
              '?a??y',
              [],
              'conetrilhrfxqukbd',
              [
                'cones',
                'trial',
                'other',
                'feral',
                'relax',
                'relay',
                'quirk',
                'baddy'
              ]),
          {'gassy', 'sappy', 'sassy', 'savvy'});
    });
  });

  group('Command line', () {
    test_command('lookup whin?', ['Lookup whin? = {whine, whiny}']);
    test_command(
        'solution -c ?a??y -a conetrilhrfxqukbd cones trial other feral relax relay quirk baddy',
        [
          'Solution -c ?a??y -a conetrilhrfxqukbd -p [] [cones, trial, other, feral, relax, relay, quirk, baddy] = {gassy, sappy, sassy, savvy}'
        ]);
  });
}

// Test the command line program
// command is the wordle command, e.g. 'lookup abba'
// output is the list of expected output lines
void test_command(String command, List<String> output) {
  final path = 'bin/wordle.dart';
  test(command, () async {
    final process =
        await Process.start('dart', ['$path', ...command.split(' ')]);
    final lineStream =
        process.stdout.transform(Utf8Decoder()).transform(LineSplitter());

    // Test output is expected
    expect(
      lineStream,
      emitsInOrder([
        // Lines of output
        ...output,
        // Assert that the stream emits a done event and nothing else
        emitsDone
      ]),
    );

    // Pipe the error output and exit code (if any)
    await process.stderr.pipe(stderr);
    var code = await process.exitCode;
    if (code != 0) {
      print('exit code: $code');
    }
  });
}

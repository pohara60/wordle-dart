import 'package:build/build.dart';
import 'wordle_builder.dart';

Builder compressBuilder(BuilderOptions options) => CompressBuilder();

/// Compresses contents of a dictionary file `name.txt` into `name.dart`.
class CompressBuilder implements Builder {
  @override
  Future build(BuildStep buildStep) async {
    // Read the dictionary
    var inputId = buildStep.inputId;
    var dictionary = await buildStep.readAsString(inputId);

    // Compress the dictionary into a string
    var builder = WordleBuilder();
    var buffer = builder.compressWordle(dictionary);

    // Write the dictionary string as Dart source.
    var copy = inputId.changeExtension('.dart');
    await buildStep.writeAsString(copy, '''// Compressed from $inputId
part of wordle;

// Word characters
var _wordCharacters = \'${WordleBuilder.wordCharacters}\';
// Characters that specify prefix length (0 to 15)
var _prefixCharacters = \'${WordleBuilder.prefixCharacters}\';
// Characters that are used as indexes into the lookup array
// Some number (default 20) are used as a one character index
// Others are used as first character of a two character index
var _lookupCharacters = \'${WordleBuilder.lookupCharacters}\';
// Characters that are used as second character of a two character index
var _lookupCharacters2 = \'${WordleBuilder.lookupCharacters2}\';
// Other special characters that can appear in a string represented as one character
// Omit \, " and ' for Javascript and \$ for Dart
var _specialCharacters = \'${WordleBuilder.specialCharacters}\';

var _buffer = \'$buffer\';''');
  }

  @override
  final buildExtensions = const {
    '.txt': ['.dart']
  };
}

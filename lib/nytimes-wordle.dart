// Compressed from wordle|lib/nytimes-wordle.txt
part of wordle;

// Word characters
var _wordCharacters = 'abcdefghijklmnopqrstuvwxyz';
// Characters that specify prefix length (0 to 15)
var _prefixCharacters = '0123456789ABCDEF';
// Characters that are used as indexes into the lookup array
// Some number (default 20) are used as a one character index
// Others are used as first character of a two character index
var _lookupCharacters = 'GHIJKLMNOPQRSTUVWXYZ#%&()*+,-./:;<=>?@[]^_`{|}~';
// Characters that are used as second character of a two character index
var _lookupCharacters2 = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ#%&()*+,-./:;<=>?@[]^_`{|}~';
// Other special characters that can appear in a string represented as one character
// Omit , " and ' for Javascript and $ for Dart
var _specialCharacters = '#%&()*+,-./:;<=>?@[]^_`{|}~';

var _buffer = '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';
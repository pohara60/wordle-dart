import 'dart:html';

import 'package:wordle/wordle.dart';

// Wordle package interface
late Wordle wordle;

// Current secret word
late String secret;

// The Wordle guesses
const NUM_GUESSES = 6;
const NUM_LETTERS = 5;
List<List<DivElement>> board = [];
List<List<WordleScore>> boardScores = [];

late int currentGuess;
late int currentLetter;

late ElementList<ButtonElement> keys;
late List<WordleScore?> keyScores;
late ButtonElement clearButton;
late ButtonElement solutionButton;
late Element solutionList;

const letterKeys = [
  KeyCode.A,
  KeyCode.B,
  KeyCode.C,
  KeyCode.D,
  KeyCode.E,
  KeyCode.F,
  KeyCode.G,
  KeyCode.H,
  KeyCode.I,
  KeyCode.J,
  KeyCode.K,
  KeyCode.L,
  KeyCode.M,
  KeyCode.N,
  KeyCode.O,
  KeyCode.P,
  KeyCode.Q,
  KeyCode.R,
  KeyCode.S,
  KeyCode.T,
  KeyCode.U,
  KeyCode.V,
  KeyCode.W,
  KeyCode.X,
  KeyCode.Y,
  KeyCode.Z
];
const delKeys = [KeyCode.DELETE, KeyCode.BACKSPACE];
const enterKeys = [KeyCode.ENTER];
const allKeys = [...letterKeys, ...delKeys, ...enterKeys];

Future main() async {
  wordle = Wordle();

  clearButton = querySelector('#clearButton')! as ButtonElement;
  clearButton.onClick.listen(newWord);

  solutionButton = querySelector('#solutionButton')! as ButtonElement;
  solutionButton.onClick.listen(getSolutions);
  solutionList = querySelector('#solutions')!;

  // Get tiles
  var tiles = querySelectorAll('.tile');
  currentGuess = 0;
  currentLetter = 0;
  for (var tile in tiles) {
    if (currentGuess == board.length) {
      board.add([]);
      boardScores.add([]);
    }
    board[currentGuess].add(tile as DivElement);
    if (++currentLetter == NUM_LETTERS) {
      currentLetter = 0;
      if (++currentGuess == NUM_GUESSES) {
        break;
      }
    }
  }
  assert(currentGuess == NUM_GUESSES && currentLetter == 0,
      'Board has correct number of tiles');

  // Get key controls
  keys = querySelectorAll('.key');
  for (var key in keys) {
    key.onClick.listen(handleClick);
  }

  // New game
  newWord(null);

  while (true) {
    KeyboardEvent k = await getkey(allKeys);
    handleKey(k.keyCode);
  }
}

void handleClick(Event e) {
  var button = e.currentTarget as ButtonElement;
  var keyCode = 0;
  if (button.text == 'ENTER') {
    keyCode = KeyCode.ENTER;
  } else if (button.text == 'BKSP') {
    keyCode = KeyCode.BACKSPACE;
  } else {
    keyCode = button.text!.codeUnitAt(0);
  }
  handleKey(keyCode);
}

void handleKey(int keyCode) {
  if (currentGuess == NUM_GUESSES) {
    // Game over
    return;
  }
  if (letterKeys.contains(keyCode)) {
    if (currentLetter < NUM_LETTERS) {
      board[currentGuess][currentLetter].text = String.fromCharCode(keyCode);
      currentLetter++;
    }
  } else if (delKeys.contains(keyCode)) {
    if (currentLetter > 0) {
      currentLetter--;
      board[currentGuess][currentLetter].text = ' ';
    }
  } else if (enterKeys.contains(keyCode)) {
    if (currentLetter == NUM_LETTERS && currentGuess < NUM_GUESSES) {
      if (getScore()) {
        currentGuess++;
        currentLetter = 0;
      }
    }
  }
}

// Credit to https://stackoverflow.com/questions/27583969/wait-for-a-keypress-in-dart
Future<KeyboardEvent> getkey([List<int>? lst]) async {
  return document.onKeyDown.firstWhere(
      (KeyboardEvent e) => ((lst == null) || (lst.contains(e.keyCode))));
}

void newWord(Event? e) {
  if (e != null) {
    // Prevent button consuing characters
    //e.preventDefault();
    var button = e.currentTarget as ButtonElement;
    button.blur();
  }
  clearSolutions();
  // Clear tile controls
  clearBoard();
  // Get secret word
  getSecret();
  // Clear keyboard
  keyScores = List.filled(keys.length, null);
  for (var key in keys) {
    key.classes.removeAll(['keyAbsent', 'keyPresent', 'keyCorrect']);
    key.classes.add('keyUnscored');
  }
}

void clearSolutions() {
  solutionList.children.clear();
}

void clearBoard() {
  // Clear current guesses
  for (var r = 0; r < NUM_GUESSES; r++) {
    for (var c = 0; c < NUM_LETTERS; c++) {
      var tile = board[r][c];
      tile.classes.clear();
      tile.classes.add('tile');
      tile.classes.add('unscored');
      tile.text = ' ';
    }
  }
  currentGuess = 0;
  currentLetter = 0;
}

void getSecret() {
  // Get secret word
  secret = wordle.getSecret();
}

bool getScore() {
  // Get score for current row using secret
  var input = board[currentGuess].fold<String>(
      '', (previousValue, element) => previousValue + (element.text ?? '?'));
  var guess = input.toLowerCase();
  var scores = wordle.getScore(secret, guess);
  if (scores.length == 0) {
    // Illegal word
    return false;
  }

  var correct = true;
  boardScores[currentGuess] = [];
  for (var i = 0; i < NUM_LETTERS; i++) {
    var tile = board[currentGuess][i];
    var score = scores[i];
    tile.classes.remove('unscored');
    if (score == WordleScore.ABSENT) {
      tile.classes.add('absent');
      correct = false;
    } else if (score == WordleScore.PRESENT) {
      tile.classes.add('present');
      correct = false;
    } else {
      tile.classes.add('correct');
    }
    updateKeyScore(input[i], score);
    boardScores[currentGuess].add(score);
  }
  if (correct) {
    // Prevent further game play
    currentGuess = NUM_GUESSES;
  }
  return true;
}

void updateKeyScore(String input, WordleScore score) {
  var index = keys.indexWhere((k) => k.text == input);
  var key = keys[index];
  var oldScore = keyScores[index];
  var newScore = oldScore;
  key.classes.remove('keyUnscored');
  if (score == WordleScore.ABSENT) {
    if (oldScore == null) {
      key.classes.add('keyAbsent');
      newScore = score;
    }
  } else if (score == WordleScore.PRESENT) {
    if (oldScore == null || oldScore == WordleScore.ABSENT) {
      key.classes.remove('keyAbsent');
      key.classes.add('keyPresent');
      newScore = score;
    }
  } else {
    if (oldScore == null ||
        oldScore == WordleScore.ABSENT ||
        oldScore == WordleScore.PRESENT) {
      key.classes.remove('keyAbsent');
      key.classes.remove('keyPresent');
      key.classes.add('keyCorrect');
      newScore = score;
    }
  }
  if (newScore != oldScore) {
    keyScores[index] = newScore;
  }
}

void getSolutions(Event e) {
  // Prevent button consuing characters
  //e.preventDefault();
  var button = e.currentTarget as ButtonElement;
  button.blur();
  // Get solutions for current guess scores
  // First get correct letters
  var correct = '?????';
  var guesses = <String>[];
  for (var g = 0; g < currentGuess; g++) {
    var input = board[g].fold<String>(
        '', (previousValue, element) => previousValue + element.text!);
    var guess = input.toLowerCase();
    guesses.add(guess);
    for (var i = 0; i < NUM_LETTERS; i++) {
      var c = guess[i];
      var s = boardScores[g][i];
      if (s == WordleScore.CORRECT) {
        if (correct[i] != c) {
          correct = correct.replaceFirst('?', c, i);
        }
      }
    }
  }
  print('getSolutions correct=$correct');
  if (currentGuess >= NUM_GUESSES) {
    // Game over
    return;
  }
  // Now get present strings, removing correct letters
  var presents = <String>[];
  for (var g = 0; g < currentGuess; g++) {
    var rest = correct;
    // Remove correct letters for this guess
    var guess = guesses[g];
    for (var i = 0; i < NUM_LETTERS; i++) {
      var c = guess[i];
      var s = boardScores[g][i];
      if (s == WordleScore.CORRECT) {
        rest = rest.replaceFirst(c, '?', i);
      }
    }
    // Compute present letters using remaining correct letters
    var present = '';
    for (var i = 0; i < NUM_LETTERS; i++) {
      var c = guess[i];
      var s = boardScores[g][i];
      var p = '?';
      if (s == WordleScore.PRESENT) {
        var index = rest.indexOf(c);
        if (index != -1) {
          // Consume present letter
          rest = rest.replaceFirst(c, '?', index);
        } else {
          p = c;
        }
      }
      present += p;
    }
    print('getSolutions guess=$guess present=$present');
    if (present != '?????') {
      presents.add(present);
    }
  }
  var solutions = wordle.getSolutions(correct, presents, null, guesses);
  for (var solution in solutions) {
    var div = DivElement();
    div.text = solution;
    div.classes.add('solution');
    solutionList.children.add(div);
  }
}

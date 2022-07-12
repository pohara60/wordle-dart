import 'dart:html';
import 'dart:math';

import 'package:wordle/wordle.dart';

// Wordle package interface
late Wordle wordle;

// Current secret word
late String secret;

// The Wordle guesses
List<List<ButtonElement>> buttons = List.filled(6, []);
List<List<WordleScore>> scores = List.filled(6, []);

late int currentRow;
late int currentCol;

late ElementList<ButtonElement> keys;
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

  // Creates buttons
  clearBoard();

  keys = querySelectorAll('.key');
  for (var key in keys) {
    key.onClick.listen(handleClick);
  }

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
  if (letterKeys.contains(keyCode)) {
    if (currentCol < 5) {
      buttons[currentRow][currentCol].text = String.fromCharCode(keyCode);
      currentCol++;
    }
  } else if (delKeys.contains(keyCode)) {
    if (currentCol > 0) {
      currentCol--;
      buttons[currentRow][currentCol].text = ' ';
    }
  } else if (enterKeys.contains(keyCode)) {
    if (currentCol == 5 && currentRow < 6) {
      getScore();
      currentRow++;
      currentCol = 0;
    }
  }
}

Future<KeyboardEvent> getkey([List<int>? lst]) async {
  return document.onKeyDown.firstWhere(
      (KeyboardEvent e) => ((lst == null) || (lst.contains(e.keyCode))));
}

void newWord(Event e) {
  solutionList.children.clear();
  clearBoard();
  getSecret();
}

void clearBoard() {
  // Clear current guesses
  for (var r = 0; r < 6; r++) {
    buttons[r] = [];
    var guesses = querySelector('#guesses-$r')!;
    guesses.children.clear();
    for (var c = 0; c < 5; c++) {
      var button = ButtonElement();
      button.classes.add('tile');
      button.classes.add('absent');
      button.text = ' ';
      button.id = 'b-$r-$c';
      buttons[r].add(button);
      guesses.children.add(button);
    }
  }
  currentRow = 0;
  currentCol = 0;
}

void getSecret() {
  // Get secret word
}

void getScore() {
  // Get score for current row using secret
}

void getSolutions(Event e) {
  // Get solutions for current guess scores
}

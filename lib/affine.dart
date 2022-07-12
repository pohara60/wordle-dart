class Affine {
  final int a;
  final int b;
  List<String> encryptTable = List.filled(26, '');
  List<String> decryptTable = List.filled(26, '');

  Affine(this.a, this.b) {
    for (var i = 0; i < 26; i++) {
      var codeA = 'a'.codeUnitAt(0);
      var e = String.fromCharCode(codeA + i);
      var value = ((a * i + b) % 26);
      var d = String.fromCharCode(codeA + value);
      // print('encrypt[$i] $e : $d, decrypt[$value] $d : $e');
      encryptTable[i] = d;
      decryptTable[value] = e;
    }
  }

  String encrypt(String word) {
    var result = '';
    var codeA = 'a'.codeUnitAt(0);
    for (var i = 0; i < word.length; i++) {
      var codeW = word.codeUnitAt(i);
      result += encryptTable[codeW - codeA];
    }
    return result;
  }

  String decrypt(String word) {
    var result = '';
    var codeA = 'a'.codeUnitAt(0);
    for (var i = 0; i < word.length; i++) {
      var codeW = word.codeUnitAt(i);
      result += decryptTable[codeW - codeA];
    }
    return result;
  }
}

void main(List<String> arguments) {
  var affine = Affine(5, 8);
  for (var word in arguments) {
    print('encrypt $word = ${affine.encrypt(word)}');
    print('decrypt $word = ${affine.decrypt(word)}');
  }
}

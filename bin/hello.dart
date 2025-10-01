import 'dart:io';
import 'dart:math';

const int size = 6;
const int shipsCount = 5;

class SeaBattle {
  List<List<String>> playerField = List.generate(size, (_) => List.filled(size, '.'));
  List<List<String>> compField = List.generate(size, (_) => List.filled(size, '.'));
  List<List<String>> compHidden = List.generate(size, (_) => List.filled(size, '.')); // скрытое поле для игрока

  final Random _rand = Random();

  void start() {
    print("=== Морской бой ===");
    _placeShipsRandom(playerField);
    _placeShipsRandom(compField);

    bool playerTurn = true;

    while (true) {
      _printFields();

      if (playerTurn) {
        print("Ваш ход (например: 2 3): ");
        List<int>? coords = _getCoords();
        if (coords == null) continue;

        bool hit = _shoot(compField, compHidden, coords[0], coords[1]);
        if (_checkWin(compField)) {
          _printFields();
          print("🎉 Вы победили!");
          break;
        }
        if (!hit) playerTurn = false;
      } else {
        print("Ход компьютера...");
        sleep(Duration(seconds: 1));
        int x, y;
        do {
          x = _rand.nextInt(size);
          y = _rand.nextInt(size);
        } while (playerField[x][y] == 'X' || playerField[x][y] == '*');

        bool hit = _shoot(playerField, playerField, x, y, show: true);
        if (_checkWin(playerField)) {
          _printFields();
          print("💻 Компьютер победил!");
          break;
        }
        if (hit) {
          print("Компьютер попал!");
        } else {
          print("Компьютер промахнулся.");
          playerTurn = true;
        }
      }
    }
  }

  void _printFields() {
    print("\nВаше поле:                    Поле противника:");

    String header = "   " + List.generate(size, (i) => i.toString()).join(" ");
    print("$header           $header");

    for (int i = 0; i < size; i++) {
      String left = "$i  " + playerField[i].join(' ');
      String right = "$i  " + compHidden[i].join(' ');
      print("$left           $right");
    }
    print("");
  }

  void _placeShipsRandom(List<List<String>> field) {
    int placed = 0;
    while (placed < shipsCount) {
      int x = _rand.nextInt(size);
      int y = _rand.nextInt(size);
      if (field[x][y] == '.') {
        field[x][y] = 'O';
        placed++;
      }
    }
  }

  List<int>? _getCoords() {
    try {
      String? input = stdin.readLineSync();
      if (input == null) return null;
      List<String> parts = input.trim().split(' ');
      if (parts.length != 2) return null;
      int x = int.parse(parts[0]);
      int y = int.parse(parts[1]);
      if (x < 0 || x >= size || y < 0 || y >= size) {
        print("❌ Координаты вне поля!");
        return null;
      }
      return [x, y];
    } catch (_) {
      print("⚠ Ошибка ввода! Введите два числа, например: 2 3");
      return null;
    }
  }

  bool _shoot(List<List<String>> realField, List<List<String>> visibleField, int x, int y, {bool show = false}) {
    if (realField[x][y] == 'O') {
      realField[x][y] = 'X';
      visibleField[x][y] = 'X';
      if (show) print("🔥 Попадание в ($x, $y)!");
      return true;
    } else {
      realField[x][y] = '*';
      visibleField[x][y] = '*';
      if (show) print("💨 Промах в ($x, $y).");
      return false;
    }
  }

  bool _checkWin(List<List<String>> field) {
    for (var row in field) {
      for (var cell in row) {
        if (cell == 'O') return false;
      }
    }
    return true;
  }
}

void main() {
  SeaBattle game = SeaBattle();
  game.start();
}

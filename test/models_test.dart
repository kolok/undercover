import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/models/player.dart';
import 'package:undercover/models/word_pair.dart';

void main() {
  group('WordPair', () {
    test('toString affiche les deux mots', () {
      expect(const WordPair('Citron', 'Orange').toString(), 'Citron / Orange');
    });
  });

  group('Player', () {
    test('getters isTaken, isCivilian et isImpostor', () {
      final civilian = Player(cardId: 0, role: Role.civilian)..name = 'Ana';
      expect(civilian.isTaken, isTrue);
      expect(civilian.isCivilian, isTrue);
      expect(civilian.isImpostor, isFalse);

      final undercover = Player(cardId: 1, role: Role.undercover);
      expect(undercover.isTaken, isFalse);
      expect(undercover.isImpostor, isTrue);

      final mrWhite = Player(cardId: 2, role: Role.mrWhite);
      expect(mrWhite.isImpostor, isTrue);
      expect(mrWhite.isCivilian, isFalse);
    });
  });
}

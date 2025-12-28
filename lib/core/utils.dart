import 'dart:math';

final _random = Random();

int randomCard() => _random.nextInt(13) + 1;
int randomDice() => _random.nextInt(6) + 1;

List<String> randomXocDia() =>
    List.generate(4, (_) => _random.nextBool() ? 'Đỏ' : 'Trắng');

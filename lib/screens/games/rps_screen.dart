import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class RPSScreen extends StatelessWidget {
  final choices = ["✊", "✋", "✌"];

  Future<void> play(BuildContext context, int user) async {
    final bot = Random().nextInt(3);
    bool win = (user == 0 && bot == 2) ||
               (user == 1 && bot == 0) ||
               (user == 2 && bot == 1);

    try {
      await WalletService.bet(100, win);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bot: ${choices[bot]} - ${win ? "Thắng" : "Thua"}")),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rock Paper Scissors")),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () => play(context, i),
              child: Text(choices[i], style: TextStyle(fontSize: 30)),
            ),
          );
        }),
      ),
    );
  }
}

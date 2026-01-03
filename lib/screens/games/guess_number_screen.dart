import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class GuessNumberScreen extends StatelessWidget {
  final secret = Random().nextInt(5) + 1;

  Future<void> play(BuildContext context, int guess) async {
    final win = guess == secret;

    try {
      await WalletService.bet(100, win);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(win ? "🎯 Đúng!" : "❌ Sai (số là $secret)")),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guess Number")),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () => play(context, i + 1),
              child: Text("${i + 1}"),
            ),
          );
        }),
      ),
    );
  }
}

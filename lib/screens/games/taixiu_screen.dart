import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class TaiXiuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tài Xỉu")),
      body: Center(
        child: ElevatedButton(
          child: Text("Cược 100"),
          onPressed: () async {
            final total = Random().nextInt(18) + 3;
            final win = total >= 11;

            try {
              await WalletService.bet(100, win);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(win ? "🎉 Thắng" : "💀 Thua")),
              );
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Không đủ point")),
              );
            }
          },
        ),
      ),
    );
  }
}

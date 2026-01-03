import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class XocDiaCasinoScreen extends StatefulWidget {
  const XocDiaCasinoScreen({super.key});

  @override
  State<XocDiaCasinoScreen> createState() => _XocDiaCasinoScreenState();
}

class _XocDiaCasinoScreenState extends State<XocDiaCasinoScreen> {
  final Random _random = Random();

  int bet = 0;
  String? selected;
  List<bool> result = [];
  bool playing = false;

  Future<void> startGame(int amount, String choice) async {
    final ok = await WalletService.deductPoint(amount);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin")),
      );
      return;
    }

    setState(() {
      bet = amount;
      selected = choice;
      playing = true;
      result = [];
    });

    await Future.delayed(const Duration(seconds: 2));
    roll();
  }

  void roll() async {
    result = List.generate(4, (_) => _random.nextBool());

    int red = result.where((e) => e).length;
    bool win = false;
    int reward = 0;

    if (selected == "chan" && red % 2 == 0) {
      win = true;
      reward = bet * 2;
    } else if (selected == "le" && red % 2 == 1) {
      win = true;
      reward = bet * 2;
    } else if (selected == "4do" && red == 4) {
      win = true;
      reward = bet * 5;
    } else if (selected == "4trang" && red == 0) {
      win = true;
      reward = bet * 5;
    }

    if (win) {
      await WalletService.addPoint(reward);
    }

    setState(() {
      playing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            win ? "🎉 Thắng $reward coin" : "💥 Thua",
          ),
        ),
      );
    }
  }

  Widget coin(bool red) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: red ? Colors.red : Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6)
        ],
      ),
    );
  }

  Widget betButton(int amount, String label) {
    return ElevatedButton(
      onPressed: playing ? null : () => startGame(amount, label),
      child: Text("$amount - $label"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎲 Xóc Đĩa Casino")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.brown.shade700,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: result.isEmpty
                      ? List.generate(4, (_) => coin(true))
                      : result.map(coin).toList(),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Wrap(
              spacing: 10,
              children: [
                betButton(100, "chan"),
                betButton(100, "le"),
                betButton(200, "4do"),
                betButton(200, "4trang"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

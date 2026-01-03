import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class DiceRollCasinoScreen extends StatefulWidget {
  const DiceRollCasinoScreen({super.key});

  @override
  State<DiceRollCasinoScreen> createState() => _DiceRollCasinoScreenState();
}

class _DiceRollCasinoScreenState extends State<DiceRollCasinoScreen> {
  final Random _random = Random();

  List<int> dice = [1, 1, 1];
  bool rolling = false;

  Future<void> play(int bet, bool tai) async {
    final ok = await WalletService.deductPoint(bet);
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("❌ Không đủ coin")));
      return;
    }

    setState(() => rolling = true);

    await Future.delayed(const Duration(seconds: 2));

    dice = List.generate(3, (_) => _random.nextInt(6) + 1);
    final total = dice.reduce((a, b) => a + b);
    final isTai = total >= 11;

    if (tai == isTai) {
      await WalletService.addPoint(bet * 2);
    }

    setState(() => rolling = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            tai == isTai ? "🎉 Thắng ${bet * 2}" : "💥 Thua ($total)")));
  }

  Widget diceBox(int value) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$value",
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎲 Tài Xỉu Casino")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dice.map(diceBox).toList(),
            ),
            const SizedBox(height: 30),
            if (!rolling)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () => play(500, true),
                      child: const Text("TÀI")),
                  ElevatedButton(
                      onPressed: () => play(500, false),
                      child: const Text("XỈU")),
                ],
              ),
            if (rolling)
              const Text("🎲 Đang lắc...",
                  style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class SlotMachineScreen extends StatefulWidget {
  const SlotMachineScreen({super.key});

  @override
  State<SlotMachineScreen> createState() => _SlotMachineScreenState();
}

class _SlotMachineScreenState extends State<SlotMachineScreen> {
  final Random _random = Random();

  final List<String> symbols = ['🍒', '🍋', '🔔', '⭐', '💎'];

  List<String> reels = ['🍒', '🍋', '🔔'];
  bool spinning = false;
  int bet = 100;

  Future<void> spin() async {
    final ok = await WalletService.deductPoint(bet);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin")),
      );
      return;
    }

    setState(() => spinning = true);

    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        reels = List.generate(
          3,
          (_) => symbols[_random.nextInt(symbols.length)],
        );
      });
    }

    checkResult();

    setState(() => spinning = false);
  }

  void checkResult() async {
    int reward = 0;

    if (reels[0] == reels[1] && reels[1] == reels[2]) {
      reward = reels[0] == '💎' ? bet * 10 : bet * 5;
    } else if (reels[0] == reels[1] ||
        reels[1] == reels[2] ||
        reels[0] == reels[2]) {
      reward = bet * 2;
    }

    if (reward > 0) {
      await WalletService.addPoint(reward);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reward > 0
                ? "🎉 Thắng $reward coin"
                : "💥 Thua rồi!",
          ),
        ),
      );
    }
  }

  Widget reel(String symbol) {
    return Container(
      width: 80,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8)
        ],
      ),
      child: Text(
        symbol,
        style: const TextStyle(fontSize: 42),
      ),
    );
  }

  Widget betButton(int amount) {
    final selected = bet == amount;
    return ElevatedButton(
      onPressed: spinning ? null : () => setState(() => bet = amount),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected ? Colors.amber : Colors.grey.shade800,
      ),
      child: Text("$amount"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎰 Slot Machine")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "🎰 SLOT MACHINE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: reels.map(reel).toList(),
            ),

            const SizedBox(height: 40),

            Wrap(
              spacing: 10,
              children: [
                betButton(100),
                betButton(200),
                betButton(500),
                betButton(1000),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: spinning ? null : spin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 60, vertical: 14),
              ),
              child: Text(
                spinning ? "ĐANG QUAY..." : "SPIN",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

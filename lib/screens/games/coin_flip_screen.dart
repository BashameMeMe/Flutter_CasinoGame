import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class CoinFlipStreakScreen extends StatefulWidget {
  const CoinFlipStreakScreen({super.key});

  @override
  State<CoinFlipStreakScreen> createState() => _CoinFlipStreakScreenState();
}

class _CoinFlipStreakScreenState extends State<CoinFlipStreakScreen> {
  final Random _random = Random();

  bool? current; // true = heads
  bool playing = false;
  int bet = 0;
  double multiplier = 1.0;

  Future<void> start(int amount) async {
    final ok = await WalletService.deductPoint(amount);
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("❌ Không đủ coin")));
      return;
    }

    setState(() {
      bet = amount;
      multiplier = 1.0;
      playing = true;
      current = _random.nextBool();
    });
  }

  void flip(bool guess) {
    final next = _random.nextBool();
    final win = guess == next;

    if (!win) {
      setState(() {
        playing = false;
        bet = 0;
        multiplier = 1.0;
        current = next;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("💥 Thua – mất cược")));
      return;
    }

    setState(() {
      current = next;
      multiplier += 0.4;
    });
  }

  Future<void> cashOut() async {
    final reward = (bet * multiplier).round();
    await WalletService.addPoint(reward);

    setState(() {
      playing = false;
      bet = 0;
      multiplier = 1.0;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("🎉 Nhận $reward coin")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🪙 Coin Flip Streak")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              current == null
                  ? "?"
                  : current!
                      ? "HEADS"
                      : "TAILS",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("💰 Cược: $bet",
                style: const TextStyle(color: Colors.white)),
            Text("🔥 Hệ số: x${multiplier.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.amber)),
            const SizedBox(height: 30),
            if (!playing)
              Wrap(
                spacing: 10,
                children: [100, 200, 500, 1000]
                    .map((e) => ElevatedButton(
                          onPressed: () => start(e),
                          child: Text("Cược $e"),
                        ))
                    .toList(),
              ),
            if (playing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () => flip(true),
                      child: const Text("HEADS")),
                  ElevatedButton(
                      onPressed: () => flip(false),
                      child: const Text("TAILS")),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: cashOut,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text("💰 CASH OUT"),
              )
            ]
          ],
        ),
      ),
    );
  }
}

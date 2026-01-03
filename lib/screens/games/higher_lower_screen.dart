import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class HigherLowerCardScreen extends StatefulWidget {
  const HigherLowerCardScreen({super.key});

  @override
  State<HigherLowerCardScreen> createState() =>
      _HigherLowerCardScreenState();
}

class _HigherLowerCardScreenState extends State<HigherLowerCardScreen> {
  final Random _random = Random();

  int currentCard = 7;
  int bet = 0;
  double multiplier = 1.0;
  bool playing = false;

  String cardLabel(int value) {
    const labels = {
      1: 'A',
      11: 'J',
      12: 'Q',
      13: 'K',
    };
    return labels[value] ?? value.toString();
  }

  Future<void> startGame(int amount) async {
    final ok = await WalletService.deductPoint(amount);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin")),
      );
      return;
    }

    setState(() {
      bet = amount;
      multiplier = 1.0;
      playing = true;
      currentCard = _random.nextInt(13) + 1;
    });
  }

  void guess(bool higher) {
    final next = _random.nextInt(13) + 1;
    final win = higher ? next > currentCard : next < currentCard;

    if (!win) {
      setState(() {
        playing = false;
        bet = 0;
        multiplier = 1.0;
        currentCard = next;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("💥 Thua – mất cược")),
      );
      return;
    }

    setState(() {
      currentCard = next;
      multiplier += 0.35;
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 Nhận $reward coin")),
      );
    }
  }

  Widget buildCard() {
    return Container(
      width: 140,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            color: Colors.black26,
            offset: Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        cardLabel(currentCard),
        style: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget infoBox(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final potential = (bet * multiplier).round();

    return Scaffold(
      appBar: AppBar(title: const Text("Higher / Lower Cards")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B1F3B), Color(0xFF0F1021)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  infoBox("TIỀN GỐC", "$bet"),
                  infoBox("HỆ SỐ", "x${multiplier.toStringAsFixed(2)}"),
                  infoBox("TẠM TÍNH", "$potential"),
                ],
              ),

              const SizedBox(height: 30),
              buildCard(),
              const SizedBox(height: 30),

              if (!playing)
                Wrap(
                  spacing: 10,
                  children: [100, 200, 500, 1000]
                      .map(
                        (e) => ElevatedButton(
                          onPressed: () => startGame(e),
                          child: Text("Cược $e"),
                        ),
                      )
                      .toList(),
                ),

              if (playing) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => guess(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                      ),
                      child: const Text("LOWER"),
                    ),
                    ElevatedButton(
                      onPressed: () => guess(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                      ),
                      child: const Text("HIGHER"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: cashOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  child: const Text(
                    "💰 KẾT THÚC – CASH OUT",
                    style: TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

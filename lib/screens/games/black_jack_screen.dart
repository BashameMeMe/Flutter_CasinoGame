import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class BlackjackScreen extends StatefulWidget {
  const BlackjackScreen({super.key});

  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  final Random _random = Random();

  List<int> player = [];
  List<int> dealer = [];
  bool playing = false;
  int bet = 500;

  int score(List<int> cards) =>
      cards.map((e) => e > 10 ? 10 : e).reduce((a, b) => a + b);

  int draw() => _random.nextInt(13) + 1;

  Future<void> start() async {
    final ok = await WalletService.deductPoint(bet);
    if (!ok) return;

    setState(() {
      player = [draw(), draw()];
      dealer = [draw()];
      playing = true;
    });
  }

  void hit() {
    setState(() => player.add(draw()));
    if (score(player) > 21) end(false);
  }

  void stand() async {
    while (score(dealer) < 17) {
      dealer.add(draw());
    }

    final p = score(player);
    final d = score(dealer);

    end(p <= 21 && (d > 21 || p > d));
  }

  Future<void> end(bool win) async {
    if (win) await WalletService.addPoint(bet * 2);

    setState(() => playing = false);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(win ? "🎉 Thắng" : "💥 Thua")));
  }

  Widget hand(String title, List<int> cards) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cards
              .map((e) => Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      "$e",
                      style: const TextStyle(fontSize: 22),
                    ),
                  ))
              .toList(),
        ),
        Text("Score: ${score(cards)}",
            style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🃏 Blackjack")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000428), Color(0xFF004e92)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            hand("Dealer", dealer),
            const SizedBox(height: 30),
            hand("Player", player),
            const SizedBox(height: 30),
            if (!playing)
              ElevatedButton(
                  onPressed: start, child: const Text("BẮT ĐẦU")),
            if (playing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: hit, child: const Text("HIT")),
                  ElevatedButton(
                      onPressed: stand, child: const Text("STAND")),
                ],
              )
          ],
        ),
      ),
    );
  }
}

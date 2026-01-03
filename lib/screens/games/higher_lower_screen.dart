import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class HigherLowerCardScreen extends StatefulWidget {
  const HigherLowerCardScreen({super.key});

  @override
  State<HigherLowerCardScreen> createState() => _HigherLowerCardScreenState();
}

class _HigherLowerCardScreenState extends State<HigherLowerCardScreen> {
  final Random _random = Random();

  int currentCard = 7;
  int bet = 0;
  double multiplier = 1.0;
  bool playing = false;

  String cardLabel(int value) {
    const labels = {1: 'A', 11: 'J', 12: 'Q', 13: 'K'};
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
    final isRed = currentCard == 1 || currentCard == 11 || currentCard == 12 || currentCard == 13;
    final suit = isRed ? '♥' : '♠';

    return Container(
      width: 160,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber[700]!, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              cardLabel(currentCard),
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: isRed ? Colors.red[800] : Colors.black87,
                shadows: const [Shadow(blurRadius: 10, color: Colors.black45)],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Text(
              suit,
              style: TextStyle(fontSize: 36, color: isRed ? Colors.red : Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Transform.rotate(
              angle: 3.14159,
              child: Text(
                suit,
                style: TextStyle(fontSize: 36, color: isRed ? Colors.red : Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoBox(String title, String value, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget betButton(int amount) {
    return GestureDetector(
      onTap: playing ? null : () => startGame(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.amber[700],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Text(
          "$amount",
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final potential = (bet * multiplier).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text("HIGHER / LOWER", style: TextStyle(letterSpacing: 1.5)),
        backgroundColor: Colors.black.withOpacity(0.3), // Nền mờ để hòa quyện
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF1B263B), Color(0xFF415A77)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      infoBox("TIỀN GỐC", "$bet coin", color: Colors.amber[300]!),
                      infoBox("HỆ SỐ", "x${multiplier.toStringAsFixed(2)}", color: Colors.green[300]!),
                      infoBox("TẠM TÍNH", "$potential coin", color: Colors.cyan[300]!),
                    ],
                  ),

                  const SizedBox(height: 40),

                  buildCard(),

                  const SizedBox(height: 40),

                  if (!playing)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [100, 200, 500, 1000].map(betButton).toList(),
                    ),

                  if (playing) ...[
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => guess(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                          ),
                          child: const Text(
                            "LOWER",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => guess(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                          ),
                          child: const Text(
                            "HIGHER",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: cashOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 10,
                        shadowColor: Colors.amber.withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "💰 CASH OUT",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
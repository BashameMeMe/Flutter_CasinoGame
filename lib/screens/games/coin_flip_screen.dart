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

  bool? currentResult; // true = Heads, false = Tails
  bool playing = false;
  int bet = 0;
  double multiplier = 1.0;

  Future<void> start(int amount) async {
    final ok = await WalletService.deductPoint(amount);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Không đủ coin"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      bet = amount;
      multiplier = 1.0;
      playing = true;
      currentResult = _random.nextBool();
    });
  }

  void flip(bool guessHeads) {
    final next = _random.nextBool();
    final win = guessHeads == next;

    if (!win) {
      setState(() {
        playing = false;
        bet = 0;
        multiplier = 1.0;
        currentResult = next;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("💥 Thua – mất cược!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      currentResult = next;
      multiplier += 0.90; // Giữ nguyên multiplier +0.90 như code của bạn
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.green[700],
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              "🎉 Nhận $reward coin!",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget coinDisplay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentResult == null
            ? Colors.grey[800]
            : currentResult!
                ? Colors.amber[400]
                : Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: currentResult == null
                ? Colors.black.withOpacity(0.4)
                : currentResult!
                    ? Colors.amber.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(color: Colors.white70, width: 4),
      ),
      child: Center(
        child: Text(
          currentResult == null
              ? "?"
              : currentResult!
                  ? "HEADS"
                  : "TAILS",
          style: TextStyle(
            fontSize: currentResult == null ? 80 : 38,
            fontWeight: FontWeight.w900,
            color: currentResult == null
                ? Colors.white70
                : currentResult!
                    ? Colors.black87
                    : Colors.black87,
            shadows: const [Shadow(blurRadius: 10, color: Colors.black54)],
          ),
        ),
      ),
    );
  }

  Widget betChip(int amount) {
    return GestureDetector(
      onTap: playing ? null : () => start(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          "$amount",
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final potential = (bet * multiplier).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text("COIN FLIP STREAK", style: TextStyle(letterSpacing: 1.5)),
        backgroundColor: Colors.black.withOpacity(0.3), // Nền mờ để hòa quyện gradient
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Nút quay trở lại
          },
        ),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  coinDisplay(),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text("CƯỢC", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("$bet", style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("HỆ SỐ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("x${multiplier.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("TẠM TÍNH", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("$potential", style: const TextStyle(color: Colors.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  if (!playing)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [100, 200, 500, 1000].map(betChip).toList(),
                    ),

                  if (playing) ...[
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => flip(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[800],
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                          ),
                          child: const Text(
                            "HEADS",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => flip(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[800],
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                          ),
                          child: const Text(
                            "TAILS",
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Text(
                          "💰 CASH OUT",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class TaiXiuScreen extends StatefulWidget {
  const TaiXiuScreen({super.key});

  @override
  State<TaiXiuScreen> createState() => _TaiXiuScreenState();
}

class _TaiXiuScreenState extends State<TaiXiuScreen> {
  final Random _random = Random();

  List<int> dice = [1, 1, 1];
  bool playing = false;
  int betAmount = 100; // Mức cược hiện tại

  Widget diceWidget(int value) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red[800]),
        ),
      ),
    );
  }

  Future<void> play() async {
    if (playing || betAmount <= 0) return;

    setState(() => playing = true);

    final newDice = List.generate(3, (_) => _random.nextInt(6) + 1);
    final total = newDice.fold(0, (sum, v) => sum + v);
    final win = total >= 11;

    try {
      await WalletService.bet(betAmount, win);

      setState(() {
        dice = newDice;
        playing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: win ? Colors.green[700] : Colors.red[800],
          content: Text(
            win ? "🎉 THẮNG! Tổng $total" : "💥 THUA! Tổng $total",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (_) {
      setState(() => playing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không đủ point!")),
      );
    }
  }

  Widget betControl() {
    return Column(
      children: [
        Text(
          "Cược: $betAmount coin",
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: playing || betAmount <= 50
                  ? null
                  : () => setState(() => betAmount -= 50),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("-", style: TextStyle(color: Colors.white, fontSize: 28)),
                ),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onLongPress: playing ? null : () => setState(() => betAmount = 100),
              onTap: playing ? null : () => setState(() => betAmount = 100),
              child: Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("Reset", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: playing ? null : () => setState(() => betAmount += 50),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("+", style: TextStyle(color: Colors.white, fontSize: 28)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Không cần extendBodyBehindAppBar nữa để AppBar hiển thị nút back chuẩn
      appBar: AppBar(
        title: const Text("TÀI XỈU"),
        backgroundColor: Colors.black.withOpacity(0.3), // Nền mờ để hòa quyện với gradient
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D1B12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber[700]!, width: 4),
                  ),
                  child: Wrap(
                    spacing: 20,
                    children: dice.map(diceWidget).toList(),
                  ),
                ),

                const SizedBox(height: 40),

                betControl(),

                const SizedBox(height: 40),

                SizedBox(
                  width: 220,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: playing ? null : play,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      playing ? "ĐANG XÓC..." : "XÓC",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
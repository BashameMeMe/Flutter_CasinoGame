import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class HigherLowerCardScreen extends StatefulWidget {
  const HigherLowerCardScreen({super.key});

  @override
  State<HigherLowerCardScreen> createState() => _HigherLowerCardScreenState();
}

class _HigherLowerCardScreenState extends State<HigherLowerCardScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  int currentCard = 7;
  int bet = 0;
  double multiplier = 1.0;
  bool playing = false;

  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String cardLabel(int value) {
    const labels = {1: 'A', 11: 'J', 12: 'Q', 13: 'K'};
    return labels[value] ?? value.toString();
  }

  String cardSuit(int value) {
    const suits = ['♥', '♠', '♦', '♣'];
    return suits[value % 4];
  }

  bool isRedSuit(int value) => value % 4 == 0 || value % 4 == 2;

  Future<void> startGame(int amount) async {
    final ok = await WalletService.deductPoint(amount);
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Không đủ coin!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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

    setState(() {
      if (win) {
        currentCard = next;
        multiplier += 0.45; // Tăng nhẹ để game hấp dẫn
      } else {
        playing = false;
        bet = 0;
        multiplier = 1.0;
        currentCard = next;
        _animController.reset();
      }
    });

    if (!mounted) return;

    if (win) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1400),
          backgroundColor: Colors.green.shade800,
          content: Text(
            "✓ Đúng! x${multiplier.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("💥 THUA – MẤT CƯỢC!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> cashOut() async {
    final reward = (bet * multiplier).round();
    await WalletService.addPoint(reward);

    setState(() {
      playing = false;
      bet = 0;
      multiplier = 1.0;
    });
    _animController.reset();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.deepOrangeAccent],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Text(
            "🎉 NHẬN $reward COIN!",
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget buildCard() {
    final suit = cardSuit(currentCard);
    final isRed = isRedSuit(currentCard);
    final color = isRed ? Colors.redAccent : Colors.black87;

    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: 240,
        height: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.6), blurRadius: 30, spreadRadius: 8),
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 25, offset: const Offset(0, 12)),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                cardLabel(currentCard),
                style: TextStyle(
                  fontSize: 140,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Text(suit, style: TextStyle(fontSize: 60, color: color)),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Text(suit, style: TextStyle(fontSize: 60, color: color)),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Transform.rotate(angle: pi, child: Text(suit, style: TextStyle(fontSize: 60, color: color))),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Transform.rotate(angle: pi, child: Text(suit, style: TextStyle(fontSize: 60, color: color))),
            ),
          ],
        ),
      ),
    );
  }

  Widget statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget betButton(int amount) {
    return GestureDetector(
      onTap: playing ? null : () => startGame(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 12),
          ],
        ),
        child: Text(
          "$amount",
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.75).clamp(220.0, 280.0);

    final potential = (bet * multiplier).round();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0D001F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Higher / Lower", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D001F), Color(0xFF1A0040), Color(0xFF25005A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    statBox("CƯỢC", "$bet", Colors.amber),
                    statBox("HỆ SỐ", "x${multiplier.toStringAsFixed(2)}", Colors.greenAccent),
                    statBox("TỔNG", "$potential", Colors.cyanAccent),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Lá bài - phần chính
              Center(child: SizedBox(width: cardWidth, child: buildCard())),

              const Spacer(flex: 2),

              // Controls
              if (!playing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [100, 200, 500, 1000, 2000].map(betButton).toList(),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton("LOWER", Colors.redAccent, false),
                      _buildActionButton("HIGHER", Colors.cyanAccent, true),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Cash Out - nút lớn nhất
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: GestureDetector(
                    onTap: cashOut,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
                        ),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(color: Colors.tealAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "💰 CASH OUT",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, bool isHigher) {
    return GestureDetector(
      onTap: () => guess(isHigher),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15)],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
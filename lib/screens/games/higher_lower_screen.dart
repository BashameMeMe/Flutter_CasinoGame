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
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _rotateAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
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
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("❌ Không đủ coin!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade700.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
      return;
    }

    setState(() {
      bet = amount;
      multiplier = 1.0;
      playing = true;
      currentCard = _random.nextInt(13) + 1;
    });

    _animController.forward();
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
      _animController.reset();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.close_rounded, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text("💥 THUA – MẤT CƯỢC!", style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          backgroundColor: Colors.red.shade900.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
      return;
    }

    setState(() {
      currentCard = next;
      multiplier += 0.40; // tăng nhẹ để game hấp dẫn hơn
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1, milliseconds: 800),
        content: Text("✓ Đúng! x${multiplier.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700.withOpacity(0.85),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.amberAccent.withOpacity(0.7), blurRadius: 30, spreadRadius: 6),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.black87, size: 36),
              const SizedBox(width: 16),
              Text(
                "🎉 NHẬN $reward COIN!",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
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
      scale: _scaleAnim,
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          return Transform.rotate(
            angle: playing ? _rotateAnim.value : 0,
            child: Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: color, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(_glowAnim.value * 0.8),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                  BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 30, offset: const Offset(0, 15)),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      cardLabel(currentCard),
                      style: TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.w900,
                        color: color,
                        shadows: const [Shadow(blurRadius: 25, color: Colors.black54)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Text(
                      suit,
                      style: TextStyle(
                        fontSize: 54,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Text(
                      suit,
                      style: TextStyle(
                        fontSize: 54,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Transform.rotate(
                      angle: pi,
                      child: Text(
                        suit,
                        style: TextStyle(
                          fontSize: 54,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Transform.rotate(
                      angle: pi,
                      child: Text(
                        suit,
                        style: TextStyle(
                          fontSize: 54,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget infoBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget betButton(int amount) {
    return GestureDetector(
      onTap: playing ? null : () => startGame(amount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.amberAccent.withOpacity(0.7),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          "$amount",
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final potential = (bet * multiplier).round();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A001A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.cyanAccent, Colors.purpleAccent, Colors.pinkAccent],
          ).createShader(bounds),
          child: const Text(
            "HIGHER / LOWER",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A001A), Color(0xFF140033), Color(0xFF1A003F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      infoBox("CƯỢC", "$bet", Colors.amberAccent),
                      infoBox("HỆ SỐ", "x${multiplier.toStringAsFixed(2)}", Colors.greenAccent),
                      infoBox("TỔNG", "$potential", Colors.cyanAccent),
                    ],
                  ),

                  const SizedBox(height: 50),

                  buildCard(),

                  const SizedBox(height: 60),

                  if (!playing)
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [100, 200, 500, 1000].map(betButton).toList(),
                    ),

                  if (playing) ...[
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGuessButton(false, "LOWER", Colors.redAccent),
                        _buildGuessButton(true, "HIGHER", Colors.cyanAccent),
                      ],
                    ),
                    const SizedBox(height: 50),

                    // CASH OUT - điểm nhấn
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: GestureDetector(
                        onTap: cashOut,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00FF9D), Color(0xFF00D4FF), Color(0xFF7B00FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(_glowAnim.value * 0.8),
                                blurRadius: 40,
                                spreadRadius: 12,
                              ),
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.6),
                                blurRadius: 60,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                          child: const Text(
                            "💰 CASH OUT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              shadows: [Shadow(blurRadius: 15, color: Colors.black54)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuessButton(bool higher, String text, Color glowColor) {
    return GestureDetector(
      onTap: () => guess(higher),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: higher
                ? [Colors.cyan.shade600, Colors.cyan.shade900]
                : [Colors.redAccent.shade700, Colors.red.shade900],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: glowColor.withOpacity(0.7), blurRadius: 25, spreadRadius: 6),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
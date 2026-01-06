import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class CoinFlipStreakScreen extends StatefulWidget {
  const CoinFlipStreakScreen({super.key});

  @override
  State<CoinFlipStreakScreen> createState() => _CoinFlipStreakScreenState();
}

class _CoinFlipStreakScreenState extends State<CoinFlipStreakScreen> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  bool? currentResult; // true = Heads, false = Tails
  bool playing = false;
  int bet = 0;
  double multiplier = 1.0;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _rotateAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> start(int amount) async {
    final ok = await WalletService.deductPoint(amount);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("❌ Không đủ coin!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade700.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() {
      bet = amount;
      multiplier = 1.0;
      playing = true;
      currentResult = null; // ẩn kết quả ban đầu
    });

    // Delay để tạo cảm giác flip
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => currentResult = _random.nextBool());
    }
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
      currentResult = next;
      multiplier += 0.95; // tăng nhẹ để game hấp dẫn hơn
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1, milliseconds: 500),
        content: Text("✓ Chuỗi thắng! x${multiplier.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700.withOpacity(0.8),
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
      currentResult = null;
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
              BoxShadow(color: Colors.amberAccent.withOpacity(0.7), blurRadius: 25, spreadRadius: 5),
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

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget coinDisplay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final coinSize = (screenWidth * 0.68).clamp(220.0, 290.0);

    return ScaleTransition(
      scale: _scaleAnim,
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          return Transform.rotate(
            angle: playing ? _rotateAnim.value : 0,
            child: Container(
              width: coinSize,
              height: coinSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: currentResult == null
                      ? [Colors.grey.shade900, Colors.grey.shade800]
                      : currentResult!
                          ? [const Color(0xFFFFD700), const Color(0xFFDAA520)]
                          : [const Color(0xFFAAAAAA), const Color(0xFF777777)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (currentResult == null
                            ? Colors.cyanAccent
                            : currentResult!
                                ? Colors.amberAccent
                                : Colors.blueGrey)
                        .withOpacity(_glowAnim.value * 0.8),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.35), width: 4),
              ),
              child: Center(
                child: currentResult == null
                    ? const Text(
                        "?",
                        style: TextStyle(
                          fontSize: 140,
                          fontWeight: FontWeight.w900,
                          color: Colors.white70,
                          shadows: [Shadow(blurRadius: 30, color: Colors.black87)],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            currentResult! ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            size: 80,
                            color: Colors.black87,
                            shadows: const [Shadow(blurRadius: 20, color: Colors.black54)],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentResult! ? "HEADS" : "TAILS",
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: 3,
                              shadows: [Shadow(blurRadius: 15, color: Colors.black87)],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget betChip(int amount) {
    return GestureDetector(
      onTap: playing ? null : () => start(amount),
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
              spreadRadius: 4,
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(bool isHeads, String text, IconData icon, Color glowColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => flip(isHeads),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHeads ? [Colors.blueAccent.shade700, Colors.cyan.shade900] : [Colors.purple.shade800, Colors.deepPurple.shade900],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(color: glowColor.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
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
      backgroundColor: const Color(0xFF0C1221),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("COIN FLIP STREAK", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C1221), Color(0xFF1A2340), Color(0xFF2A1B45)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStatItem("CƯỢC", "$bet", Colors.amberAccent),
                    _buildStatItem("HỆ SỐ", "x${multiplier.toStringAsFixed(2)}", Colors.greenAccent),
                    _buildStatItem("TỔNG", "$potential", Colors.cyanAccent),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Coin
              Center(child: coinDisplay()),

              const Spacer(flex: 1),

              if (!playing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [100, 200, 500, 1000, 2000].map(betChip).toList(),
                  ),
                ),

              if (playing) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildChoiceButton(true, "HEADS", Icons.arrow_upward_rounded, Colors.cyanAccent),
                      _buildChoiceButton(false, "TAILS", Icons.arrow_downward_rounded, Colors.purpleAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: GestureDetector(
                      onTap: cashOut,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
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
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.6),
                              blurRadius: 60,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
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
}
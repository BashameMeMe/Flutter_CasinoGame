import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class RPSScreen extends StatefulWidget {
  const RPSScreen({super.key});

  @override
  State<RPSScreen> createState() => _RPSScreenState();
}

class _RPSScreenState extends State<RPSScreen> with SingleTickerProviderStateMixin {
  final List<String> choices = ["✊", "✋", "✌️"];
  final Random _random = Random();

  int bet = 100;
  bool playing = false;

  int? userChoice;
  int? botChoice;
  String resultText = "";

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> play(int user) async {
    if (playing) return;

    final ok = await WalletService.deductPoint(bet);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin")),
      );
      return;
    }

    setState(() {
      playing = true;
      userChoice = user;
      botChoice = null;
      resultText = "🤖 Đang suy nghĩ...";
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    final bot = _random.nextInt(3);
    bool win = (user == 0 && bot == 2) ||
        (user == 1 && bot == 0) ||
        (user == 2 && bot == 1);

    bool draw = user == bot;

    int reward = 0;
    if (win) reward = bet * 2;
    if (draw) reward = bet;

    if (reward > 0) {
      await WalletService.addPoint(reward);
    }

    setState(() {
      botChoice = bot;
      resultText = win
          ? "🎉 THẮNG! +${bet * 2} coin"
          : draw
              ? "🤝 HÒA - Hoàn tiền"
              : "💥 THUA - Mất cược";
      playing = false;
    });

    if (win || draw) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: win
                    ? [const Color(0xFF00FF9D), const Color(0xFF00D084)]
                    : [Colors.cyanAccent.shade700, Colors.cyan.shade900],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (win ? Colors.cyanAccent : Colors.cyanAccent).withOpacity(0.7),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  win ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Text(
                  win ? "THẮNG LỚN! +${bet * 2}" : "HÒA - Hoàn tiền",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("💥 THUA – Mất cược", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade700.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    }
  }

  Widget betButton(int value) {
    final active = bet == value;
    return GestureDetector(
      onTap: playing ? null : () => setState(() => bet = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active
                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                : [Colors.grey.shade800, Colors.grey.shade900],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: active
              ? [BoxShadow(color: Colors.amberAccent.withOpacity(0.7), blurRadius: 20, spreadRadius: 5)]
              : [],
          border: Border.all(color: active ? Colors.amberAccent : Colors.transparent, width: 1.5),
        ),
        child: Text(
          "$value",
          style: TextStyle(
            color: active ? Colors.black87 : Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget choiceBox(String title, int? choice, bool isUser) {
    final color = choice == null
        ? Colors.grey.shade800
        : choice == 0
            ? Colors.orangeAccent
            : choice == 1
                ? Colors.lightBlueAccent
                : Colors.purpleAccent;

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(_glowAnim.value),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
                BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Center(
              child: Text(
                choice == null ? "❓" : choices[choice],
                style: const TextStyle(fontSize: 60, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget playButton(int index) {
    final color = index == 0
        ? Colors.orangeAccent
        : index == 1
            ? Colors.lightBlueAccent
            : Colors.purpleAccent;

    return GestureDetector(
      onTap: playing ? null : () => play(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 25,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Text(
            choices[index],
            style: const TextStyle(fontSize: 48, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            "✊✋✌️ KÉO BÚA BAO",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Cược
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                  ),
                  child: Text(
                    "CƯỢC: $bet COIN",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Chọn mức cược
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [100, 200, 500, 1000].map(betButton).toList(),
                ),

                const SizedBox(height: 50),

                // Hai lựa chọn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    choiceBox("BẠN", userChoice, true),
                    const Text(
                      "VS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(blurRadius: 10, color: Colors.purpleAccent)],
                      ),
                    ),
                    choiceBox("BOT", botChoice, false),
                  ],
                ),

                const SizedBox(height: 30),

                // Kết quả
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.amberAccent, Colors.orangeAccent],
                  ).createShader(bounds),
                  child: Text(
                    resultText,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                // Nút chơi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, playButton),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
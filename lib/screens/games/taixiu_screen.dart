import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class TaiXiuScreen extends StatefulWidget {
  const TaiXiuScreen({super.key});

  @override
  State<TaiXiuScreen> createState() => _TaiXiuScreenState();
}

class _TaiXiuScreenState extends State<TaiXiuScreen> with SingleTickerProviderStateMixin {
  final Random _random = Random();

  List<int> dice = [1, 1, 1];
  bool playing = false;
  int betAmount = 100;

  late AnimationController _animController;
  late Animation<double> _shakeX;
  late Animation<double> _shakeY;
  late Animation<double> _glowAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _shakeY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _rotateAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget diceWidget(int value) {
    final isHigh = value >= 4;
    final color = isHigh ? Colors.redAccent : Colors.cyanAccent;

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Transform.rotate(
          angle: playing ? _rotateAnim.value * 0.3 : 0,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(_glowAnim.value * 0.8),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
                BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: isHigh ? Colors.red.shade900 : Colors.black87,
                  shadows: const [Shadow(blurRadius: 15, color: Colors.black87)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> play() async {
    if (playing || betAmount <= 0) return;

    setState(() => playing = true);

    _animController.repeat(reverse: true);

    await Future.delayed(const Duration(seconds: 2, milliseconds: 800));

    _animController.stop();
    _animController.reset();

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
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: win
                    ? [const Color(0xFF00FF9D), const Color(0xFF00D084)]
                    : [Colors.redAccent.shade700, Colors.red.shade900],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (win ? Colors.cyanAccent : Colors.redAccent).withOpacity(0.7),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  win ? Icons.casino_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(width: 16),
                Text(
                  win ? "🎉 THẮNG! Tổng $total" : "💥 THUA! Tổng $total",
                  style: const TextStyle(
                    color: Colors.white,
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
    } catch (_) {
      setState(() => playing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Không đủ coin!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget betControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            "CƯỢC: $betAmount COIN",
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: playing || betAmount <= 50 ? null : () => setState(() => betAmount -= 50),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.redAccent, Colors.deepOrangeAccent],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 15, spreadRadius: 3),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "-50",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: playing ? null : () => setState(() => betAmount = 100),
                child: Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amberAccent, Colors.orangeAccent],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.amberAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "RESET",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: playing ? null : () => setState(() => betAmount += 50),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.greenAccent, Colors.tealAccent],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.greenAccent.withOpacity(0.6), blurRadius: 15, spreadRadius: 3),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "+50",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
            "TÀI XỈU",
            style: TextStyle(
              fontSize: 28,
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
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Khu vực xúc xắc - glassmorphic
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeX.value * (playing ? 1 : 0), _shakeY.value * (playing ? 1 : 0)),
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: Colors.amberAccent.withOpacity(_glowAnim.value * 0.8),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amberAccent.withOpacity(0.3 * _glowAnim.value),
                                blurRadius: 40,
                                spreadRadius: 15,
                              ),
                              BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 50, spreadRadius: 20),
                            ],
                          ),
                          child: Wrap(
                            spacing: 40,
                            runSpacing: 40,
                            alignment: WrapAlignment.center,
                            children: dice.map(diceWidget).toList(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Điều khiển cược
                  betControl(),

                  const SizedBox(height: 50),

                  // Nút XÓC - điểm nhấn chính
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.08).animate(
                      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GestureDetector(
                        onTap: playing ? null : play,
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
                                spreadRadius: 12,
                              ),
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.6),
                                blurRadius: 60,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              playing ? "ĐANG XÓC..." : "XÓC NGAY",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [Shadow(blurRadius: 15, color: Colors.black54)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class DiceRollCasinoScreen extends StatefulWidget {
  const DiceRollCasinoScreen({super.key});

  @override
  State<DiceRollCasinoScreen> createState() => _DiceRollCasinoScreenState();
}

class _DiceRollCasinoScreenState extends State<DiceRollCasinoScreen> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  List<int> dice = [1, 1, 1];
  bool rolling = false;

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
      TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: 0), weight: 1),
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

  Future<void> rollDice(bool isTai) async {
    if (rolling) return;

    const bet = 500;
    final ok = await WalletService.deductPoint(bet);
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
      rolling = true;
      dice = List.generate(3, (_) => _random.nextInt(6) + 1); // random ban đầu
    });

    _animController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2, milliseconds: 800));

    _animController.stop();
    _animController.reset();

    setState(() {
      dice = List.generate(3, (_) => _random.nextInt(6) + 1);
    });

    final total = dice.reduce((a, b) => a + b);
    final win = isTai == (total >= 11);

    if (win) {
      await WalletService.addPoint(bet * 2);
    }

    if (!mounted) return;

    setState(() => rolling = false);

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
                size: 38,
              ),
              const SizedBox(width: 16),
              Text(
                win ? "JACKPOT! +${bet * 2} COIN" : "THUA – Tổng: $total",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget diceBox(int value) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: value >= 4 ? Colors.redAccent : Colors.black87,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: (value >= 4 ? Colors.redAccent : Colors.cyanAccent).withOpacity(_glowAnim.value * 0.7),
                blurRadius: 25,
                spreadRadius: 5,
              ),
              BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w900,
                color: value >= 4 ? Colors.red.shade900 : Colors.black87,
                shadows: const [Shadow(blurRadius: 15, color: Colors.black87)],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget betButton(bool isTai) {
    final label = isTai ? "TÀI" : "XỈU";
    final gradientColors = isTai
        ? [const Color(0xFF00FF9D), const Color(0xFF00D4FF)]
        : [const Color(0xFFFF006E), const Color(0xFFB300FF)];

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTap: rolling ? null : () => rollDice(isTai),
        child: Container(
          width: 180,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: (isTai ? Colors.cyanAccent : Colors.pinkAccent).withOpacity(0.7),
                blurRadius: 30,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                shadows: [Shadow(blurRadius: 15, color: Colors.black54)],
              ),
            ),
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
            "TÀI XỈU VIP",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
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
                      return Transform.rotate(
                        angle: rolling ? _rotateAnim.value * 0.4 : 0,
                        child: Transform.translate(
                          offset: Offset(_shakeX.value, _shakeY.value),
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: Colors.amberAccent.withOpacity(_glowAnim.value * 0.8),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amberAccent.withOpacity(0.3 * _glowAnim.value),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 50, spreadRadius: 15),
                              ],
                            ),
                            child: Wrap(
                              spacing: 40,
                              runSpacing: 40,
                              alignment: WrapAlignment.center,
                              children: dice.map(diceBox).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  if (rolling)
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.amberAccent, Colors.orangeAccent],
                      ).createShader(bounds),
                      child: const Text(
                        "ĐANG LẮC... CHỜ JACKPOT!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  if (!rolling) ...[
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        betButton(true),
                        betButton(false),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                      ),
                      child: const Text(
                        "Cược mỗi ván: 500 coin • Tỷ lệ 1:1 • Tài (11-18) • Xỉu (3-10)",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

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
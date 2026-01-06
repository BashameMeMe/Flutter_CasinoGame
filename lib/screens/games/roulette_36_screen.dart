import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

enum BetType { number, red, black, even, odd, green }

class Roulette36Screen extends StatefulWidget {
  const Roulette36Screen({super.key});

  @override
  State<Roulette36Screen> createState() => _Roulette36ScreenState();
}

class _Roulette36ScreenState extends State<Roulette36Screen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  int betAmount = 100;
  bool spinning = false;

  BetType? betType;
  int? selectedNumber;

  int? resultNumber;

  late AnimationController _spinController;
  late Animation<double> _rotation;
  late Animation<double> _glowAnim;

  final List<int> redNumbers = [
    1, 3, 5, 7, 9, 12, 14, 16, 18,
    19, 21, 23, 25, 27, 30, 32, 34, 36
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _rotation = Tween<double>(begin: 0, end: 12 * pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  bool isRed(int n) => redNumbers.contains(n);
  bool isBlack(int n) => n != 0 && !isRed(n);

  Future<void> spin() async {
    if (betType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng chọn loại cược")),
      );
      return;
    }

    if (betType == BetType.number && selectedNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Chọn số cược")),
      );
      return;
    }

    final ok = await WalletService.deductPoint(betAmount);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin")),
      );
      return;
    }

    setState(() {
      spinning = true;
      resultNumber = null;
    });

    _spinController.reset();
    _spinController.forward();

    await Future.delayed(const Duration(seconds: 5));

    resultNumber = _random.nextInt(37); // 0-36
    checkResult();

    setState(() => spinning = false);
  }

  void checkResult() async {
    if (resultNumber == null) return;

    int reward = 0;

    switch (betType!) {
      case BetType.number:
        if (resultNumber == selectedNumber) reward = betAmount * 36;
        break;
      case BetType.red:
        if (isRed(resultNumber!)) reward = betAmount * 2;
        break;
      case BetType.black:
        if (isBlack(resultNumber!)) reward = betAmount * 2;
        break;
      case BetType.even:
        if (resultNumber != 0 && resultNumber!.isEven) reward = betAmount * 2;
        break;
      case BetType.odd:
        if (resultNumber != 0 && resultNumber!.isOdd) reward = betAmount * 2;
        break;
      case BetType.green:
        if (resultNumber == 0) reward = betAmount * 36;
        break;
    }

    if (reward > 0) {
      await WalletService.addPoint(reward);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: reward > 0
                  ? [const Color(0xFF00FF9D), const Color(0xFF00D084)]
                  : [Colors.redAccent.shade700, Colors.red.shade900],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (reward > 0 ? Colors.cyanAccent : Colors.redAccent).withOpacity(0.7),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                reward > 0 ? Icons.casino_rounded : Icons.close_rounded,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(width: 16),
              Text(
                reward > 0 ? "🎉 TRÚNG $reward COIN!" : "💥 THUA RỒI!",
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
  }

  Widget betButton(String label, BetType type) {
    final selected = betType == type;
    final glowColor = selected ? Colors.cyanAccent : Colors.transparent;

    return GestureDetector(
      onTap: spinning
          ? null
          : () {
              setState(() {
                betType = type;
                if (type != BetType.number) selectedNumber = null;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [const Color(0xFF00D4FF), const Color(0xFF7B00FF)]
                : [Colors.grey.shade800, Colors.grey.shade900],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: glowColor.withOpacity(0.6), blurRadius: 20, spreadRadius: 4),
          ],
          border: Border.all(color: selected ? Colors.cyanAccent : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget numberGrid() {
    if (betType != BetType.number) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.4)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(37, (i) {
          final selected = selectedNumber == i;
          Color color;
          if (i == 0) {
            color = Colors.greenAccent.shade700;
          } else if (isRed(i)) {
            color = Colors.redAccent;
          } else {
            color = Colors.grey.shade900;
          }

          return GestureDetector(
            onTap: spinning ? null : () => setState(() => selectedNumber = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: selected ? Border.all(color: Colors.amberAccent, width: 3) : null,
                boxShadow: selected
                    ? [BoxShadow(color: Colors.amberAccent.withOpacity(0.6), blurRadius: 12)]
                    : [],
              ),
              child: Center(
                child: Text(
                  "$i",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget betAmountButton(int value) {
    final active = betAmount == value;
    return GestureDetector(
      onTap: spinning ? null : () => setState(() => betAmount = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active
                ? [Colors.amberAccent, Colors.orangeAccent]
                : [Colors.grey.shade800, Colors.grey.shade900],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: active
              ? [BoxShadow(color: Colors.amberAccent.withOpacity(0.6), blurRadius: 15)]
              : [],
        ),
        child: Text(
          "$value",
          style: TextStyle(
            color: active ? Colors.black87 : Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final potentialWin = switch (betType) {
      BetType.number => betAmount * 36,
      BetType.red || BetType.black || BetType.even || BetType.odd => betAmount * 2,
      BetType.green => betAmount * 36,
      null => 0,
    };

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
            "ROULETTE 36",
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Bánh xe roulette - điểm nhấn
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotation.value,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.greenAccent.shade700,
                                Colors.redAccent.shade700,
                                Colors.black87,
                                Colors.redAccent.shade700,
                                Colors.black87,
                                Colors.greenAccent.shade700,
                              ],
                              stops: [0.0, 0.1, 0.5, 0.6, 0.9, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(_glowAnim.value * 0.7),
                                blurRadius: 40,
                                spreadRadius: 15,
                              ),
                              BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 50, spreadRadius: 20),
                            ],
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                          ),
                          child: Center(
                            child: spinning
                                ? const Icon(Icons.casino_rounded, size: 80, color: Colors.white70)
                                : (resultNumber != null
                                    ? Text(
                                        "$resultNumber",
                                        style: TextStyle(
                                          fontSize: 80,
                                          fontWeight: FontWeight.w900,
                                          color: resultNumber == 0
                                              ? Colors.greenAccent
                                              : isRed(resultNumber!)
                                                  ? Colors.redAccent
                                                  : Colors.white,
                                        ),
                                      )
                                    : const Text("?", style: TextStyle(fontSize: 100, color: Colors.white70))),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Potential win
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                    ),
                    child: Text(
                      "Tiềm năng thắng: $potentialWin coin",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Bet types
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      betButton("RED", BetType.red),
                      betButton("BLACK", BetType.black),
                      betButton("EVEN", BetType.even),
                      betButton("ODD", BetType.odd),
                      betButton("GREEN 0", BetType.green),
                      betButton("NUMBER", BetType.number),
                    ],
                  ),

                  const SizedBox(height: 24),
                  numberGrid(),

                  const SizedBox(height: 40),

                  // Bet amount
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [100, 200, 500, 1000].map(betAmountButton).toList(),
                  ),

                  const SizedBox(height: 50),

                  // SPIN button - điểm nhấn chính
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.08).animate(
                      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
                    ),
                    child: GestureDetector(
                      onTap: spinning ? null : spin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF006E), Color(0xFF7B00FF), Color(0xFF00D4FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(_glowAnim.value * 0.8),
                              blurRadius: 40,
                              spreadRadius: 12,
                            ),
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.6),
                              blurRadius: 60,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: Text(
                          spinning ? "ĐANG QUAY..." : "SPIN NOW",
                          style: const TextStyle(
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
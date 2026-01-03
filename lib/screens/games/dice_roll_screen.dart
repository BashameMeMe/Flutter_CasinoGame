import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class DiceRollCasinoScreen extends StatefulWidget {
  const DiceRollCasinoScreen({super.key});

  @override
  State<DiceRollCasinoScreen> createState() => _DiceRollCasinoScreenState();
}

class _DiceRollCasinoScreenState extends State<DiceRollCasinoScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  List<int> dice = [1, 1, 1];
  bool rolling = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _shakeAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> rollDice(bool isTai) async {
    if (rolling) return;

    final bet = 500;
    final ok = await WalletService.deductPoint(bet);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Không đủ coin"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => rolling = true);

    // Hiệu ứng lắc mạnh mẽ, đột phá
    _shakeController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2));
    _shakeController.stop();

    dice = List.generate(3, (_) => _random.nextInt(6) + 1);
    final total = dice.reduce((a, b) => a + b);
    final win = isTai == (total >= 11);

    if (win) {
      await WalletService.addPoint(bet * 2);
    }

    setState(() => rolling = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: win ? Colors.green[700] : Colors.red[800],
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              win ? Icons.casino_rounded : Icons.close_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 16),
            Text(
              win ? "JACKPOT! +${bet * 2}" : "Thua ($total)",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget diceBox(int value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber[600]!, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: value >= 4 ? Colors.red[800] : Colors.black87,
            shadows: const [
              Shadow(blurRadius: 8, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }

  Widget betButton(bool isTai) {
    final label = isTai ? "TÀI" : "XỈU";
    final color = isTai ? Colors.green[700]! : Colors.red[700]!;

    return GestureDetector(
      onTap: rolling ? null : () => rollDice(isTai),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
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
      appBar: AppBar(
        title: const Text(
          "TÀI XỈU VIP",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A3A),
              Color(0xFF2A1B4A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bảng lắc xúc xắc đột phá
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * (rolling ? 1 : 0), 0),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E0F0F).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.amber[600]!, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 30,
                          runSpacing: 30,
                          alignment: WrapAlignment.center,
                          children: dice.map(diceBox).toList(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                if (rolling)
                  const Text(
                    "ĐANG LẮC... JACKPOT ĐANG GẦN!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),

                if (!rolling) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      betButton(true),
                      betButton(false),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Cược mỗi ván: 500 coin",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
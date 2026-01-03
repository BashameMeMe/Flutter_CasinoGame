import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class SlotMachineScreen extends StatefulWidget {
  const SlotMachineScreen({super.key});

  @override
  State<SlotMachineScreen> createState() => _SlotMachineScreenState();
}

class _SlotMachineScreenState extends State<SlotMachineScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  final List<String> symbols = ['🍒', '🍋', '🔔', '⭐', '💎', '7️','🍅'];

  List<String> reels = ['🍒', '🍋', '🔔'];
  bool spinning = false;
  int bet = 100;

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> spin() async {
    final ok = await WalletService.deductPoint(bet);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin")),
      );
      return;
    }

    setState(() => spinning = true);
    _spinController.repeat(reverse: true);

    // Hiệu ứng quay 3 cuộn với delay khác nhau
    for (int step = 0; step < 20; step++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        reels = List.generate(
          3,
          (_) => symbols[_random.nextInt(symbols.length)],
        );
      });
    }

    _spinController.stop();

    // Kết quả cuối cùng
    reels = List.generate(3, (_) => symbols[_random.nextInt(symbols.length)]);

    checkResult();

    if (mounted) {
      setState(() => spinning = false);
    }
  }

  void checkResult() async {
    int reward = 0;

    if (reels[0] == reels[1] && reels[1] == reels[2]) {
      reward = reels[0] == '💎' ? bet * 20 : bet * 10;
    } else if (reels[0] == reels[1] ||
        reels[1] == reels[2] ||
        reels[0] == reels[2]) {
      reward = bet * 2;
    }

    if (reward > 0) {
      await WalletService.addPoint(reward);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: reward > 0 ? Colors.green[700] : Colors.red[800],
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                reward > 0 ? Icons.casino_rounded : Icons.sentiment_dissatisfied,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                reward > 0 ? "JACKPOT! +$reward" : "Thua rồi!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget reel(String symbol) {
    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber[600]!, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
          ),
        ),
      ),
    );
  }

  Widget betChip(int amount) {
    final selected = bet == amount;
    return GestureDetector(
      onTap: spinning ? null : () => setState(() => bet = amount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [Colors.amber[600]!, Colors.amber[300]!]
                : [Colors.grey[800]!, Colors.grey[900]!],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: selected ? Colors.amber.withOpacity(0.6) : Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: selected ? Border.all(color: Colors.white70, width: 2) : null,
        ),
        child: Text(
          "$amount",
          style: TextStyle(
            color: selected ? Colors.black87 : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
        title: const Text("SLOT MACHINE VIP", style: TextStyle(letterSpacing: 2)),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Tiêu đề casino
                const Text(
                  "🎰 SLOT MACHINE",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.black),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 3 cuộn slot
                AnimatedBuilder(
                  animation: _spinController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spinAnimation.value * 0.1 * (spinning ? 1 : 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.amber[700]!, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: reels.map(reel).toList(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Chọn mức cược
                if (!spinning)
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [100, 200, 500, 1000].map(betChip).toList(),
                  ),

                if (spinning)
                  const Text(
                    "ĐANG QUAY...",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                const SizedBox(height: 40),

                // Nút SPIN
                GestureDetector(
                  onTap: spinning ? null : spin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF1744), Color(0xFFD50000)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      spinning ? "QUAY..." : "SPIN",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                      ),
                    ),
                  ),
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
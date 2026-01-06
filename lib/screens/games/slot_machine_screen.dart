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
  final List<String> symbols = ['🍒', '🍋', '🍊', '🔔', '⭐', '💎', '7️⃣', '🍉', 'BAR'];
  List<String> reels = ['🍒', '🍒', '🍒'];
  bool spinning = false;
  int bet = 100;

  late AnimationController _spinController;
  late Animation<double> _spinAnim1;
  late Animation<double> _spinAnim2;
  late Animation<double> _spinAnim3;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _spinAnim1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );
    _spinAnim2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic)),
    );
    _spinAnim3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
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
        SnackBar(
          content: const Text("❌ Không đủ coin!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() => spinning = true);

    _spinController.forward(from: 0.0);

    // Hiệu ứng quay nhanh trước khi dừng dần
    for (int i = 0; i < 25; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 70));
      setState(() {
        reels = List.generate(3, (_) => symbols[_random.nextInt(symbols.length)]);
      });
    }

    // Dừng từng cuộn một cách đẹp mắt
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => reels[0] = symbols[_random.nextInt(symbols.length)]);

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => reels[1] = symbols[_random.nextInt(symbols.length)]);

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      reels[2] = symbols[_random.nextInt(symbols.length)];
      spinning = false;
    });

    _spinController.reset();

    checkResult();
  }

  void checkResult() async {
    int reward = 0;

    if (reels[0] == reels[1] && reels[1] == reels[2]) {
      // Jackpot
      if (reels[0] == '💎') reward = bet * 25;
      else if (reels[0] == '7️⃣') reward = bet * 15;
      else reward = bet * 10;
    } else if (reels[0] == reels[1] || reels[1] == reels[2] || reels[0] == reels[2]) {
      reward = bet * 2;
    }

    if (reward > 0) {
      await WalletService.addPoint(reward);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: reward > 0
                  ? [Colors.green.shade600, Colors.green.shade900]
                  : [Colors.red.shade700, Colors.red.shade900],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (reward > 0 ? Colors.green : Colors.red).withOpacity(0.7),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reward > 0 ? "🎰 JACKPOT! +$reward" : "😔 Thua rồi!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget reel(String symbol, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value * 300 - 300), // Cuộn từ trên xuống
          child: Container(
            width: 110,
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.85), Colors.grey.shade900],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.shade600, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                symbol,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(blurRadius: 15, color: Colors.black87),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget betChip(int amount) {
    final selected = bet == amount;
    return GestureDetector(
      onTap: spinning ? null : () => setState(() => bet = amount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [Colors.amber.shade500, Colors.orange.shade700]
                : [Colors.grey.shade800, Colors.grey.shade900],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: selected ? Colors.amber.withOpacity(0.6) : Colors.black.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          ],
          border: selected ? Border.all(color: Colors.amberAccent, width: 2) : null,
        ),
        child: Text(
          "$amount",
          style: TextStyle(
            color: selected ? Colors.black87 : Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amberAccent, Colors.orangeAccent, Colors.deepOrangeAccent],
          ).createShader(bounds),
          child: const Text(
            "SLOT MACHINE VIP",
            style: TextStyle(
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
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF141A2E),
              Color(0xFF1E2640),
              Color(0xFF2A1B4A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title with glow
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.amberAccent, Colors.orangeAccent],
                  ).createShader(bounds),
                  child: const Text(
                    "🎰 SLOT MACHINE",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 15, color: Colors.black87)],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Reels container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.9), Colors.grey.shade900.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.amber.shade700, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      reel(reels[0], _spinAnim1),
                      reel(reels[1], _spinAnim2),
                      reel(reels[2], _spinAnim3),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Bet selection
                if (!spinning)
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [100, 200, 500, 1000].map(betChip).toList(),
                  ),

                if (spinning)
                  const Text(
                    "ĐANG QUAY... CHỜ JACKPOT! 🎰",
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                    ),
                  ),

                const SizedBox(height: 50),

                // Spin Button
                GestureDetector(
                  onTap: spinning ? null : spin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade900],
                      ),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.7),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Text(
                      spinning ? "QUAY..." : "SPIN NOW!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
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
    );
  }
}
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
  final List<String> symbols = ['🍒', '🍋', '🍊', '🔔', '⭐', '💎', '7️⃣', '🍉', '💥'];
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
      duration: const Duration(milliseconds: 2200),
    );

    _spinAnim1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );
    _spinAnim2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic)),
    );
    _spinAnim3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  // ── Spin logic giữ nguyên, chỉ tối ưu thời gian một chút ──
  Future<void> spin() async {
    final ok = await WalletService.deductPoint(bet);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin!"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => spinning = true);
    _spinController.forward(from: 0.0);

    // Quay nhanh ban đầu
    for (int i = 0; i < 28; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 65));
      setState(() {
        reels = List.generate(3, (_) => symbols[_random.nextInt(symbols.length)]);
      });
    }

    // Dừng dần từng reel
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => reels[0] = symbols[_random.nextInt(symbols.length)]);

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => reels[1] = symbols[_random.nextInt(symbols.length)]);

    await Future.delayed(const Duration(milliseconds: 400));
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
      if (reels[0] == '💎') reward = bet * 25;
      else if (reels[0] == '7️⃣') reward = bet * 15;
      else reward = bet * 10;
    } else if (reels[0] == reels[1] || reels[1] == reels[2] || reels[0] == reels[2]) {
      reward = bet * 2;
    }

    if (reward > 0) await WalletService.addPoint(reward);

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
            gradient: LinearGradient(
              colors: reward > 0
                  ? [Colors.green.shade700, Colors.green.shade900]
                  : [Colors.red.shade700, Colors.red.shade900],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            reward > 0 ? "🎉 +$reward coin!" : "😔 Thua rồi...",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget reel(String symbol, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, animation.value * 400 - 400),
          child: Container(
            width: 110,
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade700, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                symbol,
                style: const TextStyle(fontSize: 78, fontWeight: FontWeight.w900),
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
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [Colors.amber.shade600, Colors.orange.shade800]
                : [Colors.grey.shade800, Colors.grey],
          ),
          borderRadius: BorderRadius.circular(30),
          border: selected ? Border.all(color: Colors.amberAccent, width: 2) : null,
        ),
        child: Text(
          "$amount",
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final reelSize = (screenWidth - 80).clamp(280.0, 360.0); // responsive width

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0C1221),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("🎰 Slot VIP", style: TextStyle(fontWeight: FontWeight.bold)),
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

              // Reels - chiếm phần lớn màn hình
              Expanded(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: reelSize + 60),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.amber.shade700, width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 30),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        reel(reels[0], _spinAnim1),
                        reel(reels[1], _spinAnim2),
                        reel(reels[2], _spinAnim3),
                      ],
                    ),
                  ),
                ),
              ),

              // Bet selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const Text(
                      "Chọn mức cược",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (!spinning)
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [100, 200, 500, 1000, 2000].map(betChip).toList(),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "ĐANG QUAY... 🎰",
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Spin Button - to & nổi bật
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                child: GestureDetector(
                  onTap: spinning ? null : spin,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: spinning
                            ? [Colors.grey.shade800, Colors.grey.shade900]
                            : [Colors.red.shade700, Colors.red.shade900],
                      ),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: (spinning ? Colors.grey : Colors.redAccent).withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        spinning ? "ĐANG QUAY..." : "SPIN NOW!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class XocDiaCasinoScreen extends StatefulWidget {
  const XocDiaCasinoScreen({super.key});

  @override
  State<XocDiaCasinoScreen> createState() => _XocDiaCasinoScreenState();
}

class _XocDiaCasinoScreenState extends State<XocDiaCasinoScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  final Map<String, int> bets = {"chan": 0, "le": 0, "4do": 0, "4trang": 0};

  List<bool> result = [];
  bool playing = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeX;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void addBet(String key, int amount) {
    if (playing) return;
    setState(() => bets[key] = (bets[key] ?? 0) + amount);
  }

  void clearAll() {
    if (playing) return;
    setState(() => bets.updateAll((_, __) => 0));
  }

  int get total => bets.values.fold(0, (a, b) => a + b);

  Future<void> play() async {
    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Đặt cược trước nhé!")),
      );
      return;
    }

    final ok = await WalletService.deductPoint(total);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin")),
      );
      return;
    }

    setState(() {
      playing = true;
      result = [];
    });

    _shakeController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
    _shakeController.stop();
    _shakeController.reset();

    result = List.generate(4, (_) => _random.nextBool());
    final redCount = result.where((e) => e).length;

    int win = 0;
    if (bets["chan"]! > 0 && redCount % 2 == 0) win += bets["chan"]! * 2;
    if (bets["le"]! > 0 && redCount % 2 == 1) win += bets["le"]! * 2;
    if (bets["4do"]! > 0 && redCount == 4) win += bets["4do"]! * 10; // Tăng tỷ lệ để hấp dẫn hơn
    if (bets["4trang"]! > 0 && redCount == 0) win += bets["4trang"]! * 10;

    if (win > 0) {
      await WalletService.addPoint(win);
    }

    setState(() => playing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: win > 0
                  ? [const Color(0xFF00FF9D), const Color(0xFF00D084)]
                  : [Colors.redAccent.shade700, Colors.red.shade900],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (win > 0 ? Colors.cyanAccent : Colors.redAccent).withOpacity(0.7),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                win > 0 ? Icons.casino_rounded : Icons.close_rounded,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(width: 16),
              Text(
                win > 0 ? "🎉 THẮNG $win COIN!" : "💥 THUA – Mất cược",
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

  Widget dice(bool isRed) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isRed ? const Color(0xFFE53935) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 3),
            boxShadow: [
              BoxShadow(
                color: (isRed ? Colors.redAccent : Colors.cyanAccent).withOpacity(_glowAnim.value * 0.8),
                blurRadius: 25,
                spreadRadius: 8,
              ),
              BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Center(
            child: Text(
              isRed ? "ĐỎ" : "TRẮNG",
              style: TextStyle(
                color: isRed ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget betChip(String label, String key, int step, Color baseColor) {
    final amt = bets[key] ?? 0;
    final active = amt > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: () => setState(() => bets[key] = 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 130,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: active
                    ? [baseColor, baseColor.withOpacity(0.7)]
                    : [baseColor.withOpacity(0.5), baseColor.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: active ? Border.all(color: Colors.white70, width: 2) : null,
              boxShadow: active
                  ? [BoxShadow(color: baseColor.withOpacity(0.7), blurRadius: 20, spreadRadius: 5)]
                  : [],
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$amt",
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
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          width: 90,
          child: ElevatedButton(
            onPressed: playing ? null : () => addBet(key, step),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black87,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              shadowColor: Colors.amber.withOpacity(0.6),
            ),
            child: Text(
              "+ $step",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
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
            colors: [Colors.amberAccent, Colors.orangeAccent, Colors.deepOrangeAccent],
          ).createShader(bounds),
          child: const Text(
            "XÓC ĐĨA",
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
        actions: [
          if (total > 0 && !playing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                onPressed: clearAll,
                tooltip: "Xóa cược",
              ),
            ),
        ],
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
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Bát xóc đĩa - điểm nhấn
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeX.value * (playing ? 1 : 0), 0),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E2723).withOpacity(0.95),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amberAccent.withOpacity(playing ? _glowAnim.value : 0.6),
                            width: 6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amberAccent.withOpacity(_glowAnim.value * 0.6),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                            BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 50, spreadRadius: 20),
                          ],
                        ),
                        child: Center(
                          child: result.isEmpty
                              ? const Text(
                                  "ĐẶT CƯỢC → XÓC",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                )
                              : Wrap(
                                  spacing: 24,
                                  runSpacing: 24,
                                  alignment: WrapAlignment.center,
                                  children: result.map(dice).toList(),
                                ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Tổng cược
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                  ),
                  child: Text(
                    "TỔNG CƯỢC: $total COIN",
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Các lựa chọn cược
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      betChip("CHẴN", "chan", 100, Colors.green.shade800),
                      betChip("LẺ", "le", 100, Colors.purple.shade800),
                      betChip("4 ĐỎ", "4do", 200, Colors.red.shade800),
                      betChip("4 TRẮNG", "4trang", 200, Colors.blueGrey.shade800),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Nút XÓC NGAY - điểm nhấn
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.08).animate(
                    CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GestureDetector(
                      onTap: playing ? null : play,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFFA000), Color(0xFFFF6F00)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amberAccent.withOpacity(_glowAnim.value * 0.8),
                              blurRadius: 40,
                              spreadRadius: 12,
                            ),
                            BoxShadow(
                              color: Colors.orangeAccent.withOpacity(0.6),
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
                              color: Colors.black87,
                              letterSpacing: 3,
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
    );
  }
}
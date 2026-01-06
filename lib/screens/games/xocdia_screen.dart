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
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void addBet(String key, int amount) {
    if (playing) return;
    setState(() {
      bets[key] = (bets[key] ?? 0) + amount;
    });
  }

  void clearBet(String key) {
    if (playing) return;
    setState(() => bets[key] = 0);
  }

  void clearAll() {
    if (playing) return;
    setState(() => bets.updateAll((_, __) => 0));
  }

  int get totalBet => bets.values.fold(0, (a, b) => a + b);

  Future<void> play() async {
    if (totalBet == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng đặt cược trước!")),
      );
      return;
    }

    final ok = await WalletService.deductPoint(totalBet);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin!")),
      );
      return;
    }

    setState(() {
      playing = true;
      result = [];
    });

    _shakeController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 3));
    _shakeController.stop();
    _shakeController.reset();

    result = List.generate(4, (_) => _random.nextBool());
    final redCount = result.where((e) => e).length;

    int win = 0;
    if (bets["chan"]! > 0 && redCount % 2 == 0) win += bets["chan"]! * 2;
    if (bets["le"]! > 0 && redCount % 2 == 1) win += bets["le"]! * 2;
    if (bets["4do"]! > 0 && redCount == 4) win += bets["4do"]! * 10;
    if (bets["4trang"]! > 0 && redCount == 0) win += bets["4trang"]! * 10;

    if (win > 0) await WalletService.addPoint(win);

    setState(() => playing = false);

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
              colors: win > 0
                  ? [Colors.green.shade700, Colors.green.shade900]
                  : [Colors.red.shade700, Colors.red.shade900],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            win > 0 ? "🎉 THẮNG $win COIN!" : "😔 THUA – Mất cược",
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

  Widget dice(bool isRed) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isRed ? Colors.red.shade700 : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 3),
        boxShadow: [
          BoxShadow(
            color: (isRed ? Colors.red : Colors.white).withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          isRed ? "ĐỎ" : "TRẮNG",
          style: TextStyle(
            color: isRed ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget betOption(String label, String key, Color color) {
    final amount = bets[key] ?? 0;
    final active = amount > 0;

    return Column(
      children: [
        GestureDetector(
          onTap: playing ? null : () => clearBet(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: active ? [color, color.withOpacity(0.7)] : [color.withOpacity(0.4), color.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: active ? Border.all(color: Colors.white70, width: 2) : null,
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  amount > 0 ? "$amount" : "-",
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white60,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chipButton("+100", () => addBet(key, 100), Colors.amber.shade700),
            const SizedBox(width: 8),
            _chipButton("+500", () => addBet(key, 500), Colors.amber.shade800),
          ],
        ),
      ],
    );
  }

  Widget _chipButton(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: playing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bowlSize = (screenWidth * 0.75).clamp(260.0, 320.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0C001F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("XÓC ĐĨA", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (totalBet > 0 && !playing)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: clearAll,
              tooltip: "Xóa hết cược",
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C001F), Color(0xFF1A0042), Color(0xFF28005A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Bát xóc đĩa
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(playing ? _shakeAnim.value * 1.5 : 0, 0),
                        child: Container(
                          width: bowlSize,
                          height: bowlSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E2723),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.amberAccent,
                              width: playing ? 8 : 5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(playing ? 0.6 : 0.4),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: result.isEmpty
                                ? const Text(
                                    "XÓC ĐĨA",
                                    style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                : Wrap(
                                    spacing: 20,
                                    runSpacing: 20,
                                    children: result.map(dice).toList(),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Tổng cược
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "TỔNG CƯỢC: $totalBet COIN",
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Các lựa chọn cược
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    betOption("CHẴN", "chan", Colors.green.shade700),
                    betOption("LẺ", "le", Colors.purple.shade700),
                    betOption("4 ĐỎ", "4do", Colors.red.shade700),
                    betOption("4 TRẮNG", "4trang", Colors.blueGrey.shade700),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nút XÓC
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GestureDetector(
                  onTap: playing ? null : play,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: playing
                            ? [Colors.grey.shade800, Colors.grey.shade900]
                            : [Colors.amber.shade700, Colors.deepOrange.shade800],
                      ),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: (playing ? Colors.grey : Colors.amber).withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        playing ? "ĐANG XÓC..." : "XÓC NGAY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
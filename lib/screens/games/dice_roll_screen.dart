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

  // Map lưu cược: key là loại cược, value là số coin đặt
  final Map<String, int> bets = {};

  late AnimationController _animController;
  late Animation<double> _shakeX;
  late Animation<double> _shakeY;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -15, end: 15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 15, end: -15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _shakeY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get totalBet => bets.values.fold(0, (sum, v) => sum + v);

  void placeBet(String type, int amount) {
    if (rolling) return;
    setState(() {
      bets[type] = (bets[type] ?? 0) + amount;
    });
  }

  void clearAllBets() {
    if (rolling) return;
    setState(() => bets.clear());
  }

  Future<void> roll() async {
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
      rolling = true;
      dice = List.generate(3, (_) => _random.nextInt(6) + 1);
    });

    _animController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 3));

    _animController.stop();
    _animController.reset();

    setState(() {
      dice = List.generate(3, (_) => _random.nextInt(6) + 1);
    });

    final total = dice.reduce((a, b) => a + b);
    final isTriple = dice[0] == dice[1] && dice[1] == dice[2];
    final tripleNumber = isTriple ? dice[0] : 0;

    int win = 0;

    // Tính thắng thua từng loại cược
    if (bets.containsKey('tai') && total >= 11) win += (bets['tai'] ?? 0) * 2;
    if (bets.containsKey('xiu') && total <= 10) win += (bets['xiu'] ?? 0) * 2;

    // Cược tổng điểm (tỷ lệ cao hơn với số hiếm)
    for (int sum = 4; sum <= 17; sum++) {
      final key = 'total_$sum';
      if (bets.containsKey(key) && total == sum) {
        final multiplier = (sum == 4 || sum == 17) ? 60 : (sum == 5 || sum == 16) ? 30 : 18;
        win += (bets[key] ?? 0) * multiplier;
      }
    }

    // Triple cụ thể
    for (int num = 1; num <= 6; num++) {
      final key = 'triple_$num';
      if (bets.containsKey(key) && isTriple && tripleNumber == num) {
        win += (bets[key] ?? 0) * 150;
      }
    }

    // Any Triple
    if (bets.containsKey('any_triple') && isTriple) {
      win += (bets['any_triple'] ?? 0) * 30;
    }

    if (win > 0) {
      await WalletService.addPoint(win);
    }

    setState(() => rolling = false);

    if (!mounted) return;

    final resultText = win > 0
        ? "🎉 THẮNG $win COIN!"
        : "😔 THUA – Tổng: $total";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: win > 0 ? [Colors.green.shade700, Colors.green.shade900] : [Colors.red.shade700, Colors.red.shade900],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            resultText,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // Xóa cược sau mỗi ván (có thể comment nếu muốn giữ lại)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => bets.clear());
    });
  }

  Widget diceFace(int value) {
    final isHigh = value >= 4;
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isHigh ? Colors.redAccent : Colors.black87, width: 4),
            boxShadow: [
              BoxShadow(
                color: (isHigh ? Colors.redAccent : Colors.cyanAccent).withOpacity(_glowAnim.value * 0.7),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 58,
                fontWeight: FontWeight.w900,
                color: isHigh ? Colors.red.shade900 : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget betChip(String label, String key, int amount, Color color) {
    final current = bets[key] ?? 0;
    return Column(
      children: [
        GestureDetector(
          onTap: rolling ? null : () => placeBet(key, amount),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 110,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(16),
              border: current > 0 ? Border.all(color: Colors.white70, width: 2) : null,
            ),
            child: Column(
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
                Text(
                  current > 0 ? '$current' : '0',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: rolling ? null : () => placeBet(key, amount),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('+ $amount', style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0B001F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("TÀI XỈU VIP", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (totalBet > 0 && !rolling)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: clearAllBets,
              tooltip: "Xóa cược",
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B001F), Color(0xFF1A0040), Color(0xFF280060)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Khu vực xúc xắc
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(rolling ? _shakeX.value : 0, rolling ? _shakeY.value : 0),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.amberAccent, width: 4),
                          ),
                          child: Wrap(
                            spacing: 30,
                            runSpacing: 30,
                            alignment: WrapAlignment.center,
                            children: dice.map(diceFace).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Tổng cược & nút lắc
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tổng cược: $totalBet coin",
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: rolling ? null : roll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: rolling
                                ? [Colors.grey.shade800, Colors.grey.shade900]
                                : [Colors.amber.shade700, Colors.deepOrange.shade800],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          rolling ? "ĐANG LẮC..." : "LẮC NGAY",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Các loại cược
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      betChip("TÀI (11-18)", "tai", 500, Colors.cyan.shade700),
                      const SizedBox(width: 16),
                      betChip("XỈU (3-10)", "xiu", 500, Colors.pink.shade700),
                      const SizedBox(width: 16),
                      betChip("BỘ BA BẤT KỲ", "any_triple", 200, Colors.purple.shade700),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Triple cụ thể
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(6, (i) {
                    final num = i + 1;
                    return betChip("$num $num $num", "triple_$num", 100, Colors.red.shade800);
                  }),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
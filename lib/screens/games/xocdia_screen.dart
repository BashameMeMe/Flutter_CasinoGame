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

  late AnimationController _shake;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _shakeAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _shake, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _shake.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đặt cược trước nhé!")));
      return;
    }

    final ok = await WalletService.deductPoint(total);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không đủ coin")));
      return;
    }

    setState(() {
      playing = true;
      result = [];
    });

    _shake.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2));
    _shake.stop();

    result = List.generate(4, (_) => _random.nextBool());
    final red = result.where((e) => e).length;

    int win = 0;
    if (bets["chan"]! > 0 && red % 2 == 0) win += bets["chan"]! * 2;
    if (bets["le"]! > 0 && red % 2 == 1) win += bets["le"]! * 2;
    if (bets["4do"]! > 0 && red == 4) win += bets["4do"]! * 5;
    if (bets["4trang"]! > 0 && red == 0) win += bets["4trang"]! * 5;

    if (win > 0) await WalletService.addPoint(win);

    setState(() => playing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: win > 0 ? Colors.green[700] : Colors.red[800],
        content: Text(
          win > 0 ? "🎉 THẮNG $win" : "💥 Thua",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget dice(bool red) => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: red ? const Color(0xFFE53935) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white70, width: 2),
          boxShadow: [
            BoxShadow(
              color: red ? Colors.redAccent.withOpacity(0.6) : Colors.black38,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            red ? "ĐỎ" : "TRẮNG",
            style: TextStyle(
              color: red ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget betChip(String label, String key, int step, Color color) {
    final amt = bets[key] ?? 0;
    final bool active = amt > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: () => setState(() => bets[key] = 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 110,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? color : color.withOpacity(0.45),
              borderRadius: BorderRadius.circular(16),
              border: active ? Border.all(color: Colors.white70, width: 2) : null,
              boxShadow: active
                  ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 12, offset: const Offset(0, 6))]
                  : [],
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "$amt",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          width: 80,
          child: ElevatedButton(
            onPressed: playing ? null : () => addBet(key, step),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("+ $step", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Không dùng extendBodyBehindAppBar nữa để AppBar có nút back chuẩn
      appBar: AppBar(
        title: const Text("XÓC ĐĨA", style: TextStyle(fontSize: 20, letterSpacing: 1.2)),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        actions: [
          if (total > 0 && !playing)
            IconButton(
              icon: const Icon(Icons.refresh, size: 22),
              onPressed: clearAll,
              tooltip: "Xóa cược",
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                AnimatedBuilder(
                  animation: _shake,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(_shakeAnim.value * (playing ? 1 : 0), 0),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E2723).withOpacity(0.95),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber[700]!, width: 6),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 25, spreadRadius: 5),
                        ],
                      ),
                      child: Center(
                        child: result.isEmpty
                            ? const Text(
                                "ĐẶT CƯỢC → XÓC",
                                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            : Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: result.map(dice).toList(),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Tổng cược: $total coin",
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 6,
                    childAspectRatio: 0.85,
                    children: [
                      betChip("Chẵn", "chan", 100, Colors.green[800]!),
                      betChip("Lẻ", "le", 100, Colors.purple[800]!),
                      betChip("4 Đỏ", "4do", 200, Colors.red[800]!),
                      betChip("4 Trắng", "4trang", 200, Colors.blueGrey[800]!),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: playing ? null : play,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 8,
                        shadowColor: Colors.amber.withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          playing ? "ĐANG XÓC..." : "XÓC NGAY",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
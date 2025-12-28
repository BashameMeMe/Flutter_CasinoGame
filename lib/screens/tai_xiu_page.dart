import 'package:flutter/material.dart';
import 'dart:math';
import '../core/auth_service.dart';

class TaiXiuPage extends StatefulWidget {
  const TaiXiuPage({super.key});

  @override
  State<TaiXiuPage> createState() => _TaiXiuPageState();
}

class _TaiXiuPageState extends State<TaiXiuPage>
    with SingleTickerProviderStateMixin {
  final AuthService auth = AuthService();
  final TextEditingController betCtrl = TextEditingController(text: '100');

  String choice = 'Tài';
  String resultText = '';
  bool isPlaying = false;
  List<int> dices = [];

  late AnimationController _diceController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shakeAnim = Tween(begin: -0.15, end: 0.15)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_diceController);
  }

  @override
  void dispose() {
    _diceController.dispose();
    betCtrl.dispose();
    super.dispose();
  }

  Future<void> play(int balance) async {
    if (isPlaying) return;

    int bet = int.tryParse(betCtrl.text) ?? 0;
    if (bet <= 0 || bet > balance) return;

    setState(() {
      isPlaying = true;
      resultText = '';
      dices.clear();
    });

    /// 🔻 TRỪ TIỀN TRƯỚC
    await auth.changeBalance(balance - bet);

    await _diceController.forward(from: 0);

    dices = [
      Random().nextInt(6) + 1,
      Random().nextInt(6) + 1,
      Random().nextInt(6) + 1,
    ];

    int total = dices.reduce((a, b) => a + b);
    String kq = total >= 11 ? 'Tài' : 'Xỉu';

    if (kq == choice) {
      /// ✅ THẮNG → TRẢ GẤP ĐÔI
      await auth.changeBalance(balance + bet);
      resultText = '🎉 $total → THẮNG';
      showMoneyEffect(context);
    } else {
      resultText = '💥 $total → THUA';
    }

    setState(() => isPlaying = false);
  }

  Widget _diceBox(int? value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value == null ? Colors.white24 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: value == null
            ? []
            : const [
                BoxShadow(color: Colors.black45, blurRadius: 8),
              ],
      ),
      child: value == null
          ? const SizedBox()
          : Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.userStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data()!;
        final balance = data['balance'];

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B0F1A), Color(0xFF141E30)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  /// HEADER
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '💰 $balance',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'TÀI XỈU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// SÂN KHẤU
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _diceController,
                            builder: (_, __) {
                              return Transform.rotate(
                                angle: _shakeAnim.value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: dices.isEmpty
                                      ? List.generate(3, (_) => _diceBox(null))
                                      : dices
                                          .map((e) => _diceBox(e))
                                          .toList(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            resultText,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// CONTROL PANEL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        /// CHỌN TÀI / XỈU
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: ['Tài', 'Xỉu'].map((e) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: ChoiceChip(
                                label: Text(e),
                                selected: choice == e,
                                selectedColor: Colors.amber,
                                onSelected: isPlaying
                                    ? null
                                    : (_) => setState(() => choice = e),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),

                        /// TIỀN CƯỢC
                        TextField(
                          controller: betCtrl,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.black54,
                            hintText: 'Tiền cược',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        /// NÚT LẮC
                        ElevatedButton(
                          onPressed:
                              isPlaying ? null : () => play(balance),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPlaying ? Colors.grey : Colors.amber,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isPlaying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'LẮC',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 💰 HIỆU ỨNG TIỀN
void showMoneyEffect(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 120,
      left: MediaQuery.of(context).size.width / 2 - 40,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: -120),
        duration: const Duration(milliseconds: 800),
        builder: (_, value, child) => Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (-value / 120),
            child: child,
          ),
        ),
        child: const Text(
          '+ 💰',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 900), entry.remove);
}

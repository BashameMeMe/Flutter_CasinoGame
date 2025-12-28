import 'dart:math';
import 'package:flutter/material.dart';
import '../core/auth_service.dart';

class HigherLowerPage extends StatefulWidget {
  const HigherLowerPage({super.key});

  @override
  State<HigherLowerPage> createState() => _HigherLowerPageState();
}

class _HigherLowerPageState extends State<HigherLowerPage>
    with SingleTickerProviderStateMixin {
  final auth = AuthService();
  final betCtrl = TextEditingController(text: '100');
  final rnd = Random();

  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  int currentCard = 0;
  int nextCard = 0;
  String message = '';
  bool isPlaying = false;
  bool hasResult = false;

  @override
  void initState() {
    super.initState();
    currentCard = _randomCard();

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnim = Tween(begin: 0.0, end: pi)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_flipCtrl);
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    betCtrl.dispose();
    super.dispose();
  }

  int _randomCard() => rnd.nextInt(13) + 1;

  Future<void> play(String choice) async {
    if (isPlaying) return;

    final bet = int.tryParse(betCtrl.text) ?? 0;
    if (bet <= 0) return;

    if (!await auth.canBet(bet)) {
      setState(() => message = '❌ Không đủ tiền');
      return;
    }

    setState(() {
      isPlaying = true;
      hasResult = false;
      message = '';
    });

    // 🔻 trừ tiền trước
    await auth.changeBalance(-bet);

    nextCard = _randomCard();
    await _flipCtrl.forward(from: 0);

    bool win = choice == 'Higher'
        ? nextCard > currentCard
        : nextCard < currentCard;

    if (win) {
      await auth.changeBalance(bet * 2);
      message = '🎉 THẮNG';
    } else {
      message = '💥 THUA';
    }

    setState(() {
      currentCard = nextCard;
      hasResult = true;
      isPlaying = false;
    });
  }

  Widget card(int value) {
    return Container(
      width: 100,
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10),
        ],
      ),
      child: Text(
        value.toString(),
        style: const TextStyle(
          fontSize: 48,
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

        final user = snapshot.data!.data()!;
        final balance = user['balance'] ?? 0;

        return Scaffold(
          backgroundColor: const Color(0xFF0B0F1A),
          body: SafeArea(
            child: Column(
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
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
                        'HIGHER / LOWER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// CARD STAGE
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _flipAnim,
                      builder: (_, child) {
                        final isBack = _flipAnim.value < pi / 2;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(_flipAnim.value),
                          child: isBack
                              ? card(currentCard)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(pi),
                                  child: card(nextCard),
                                ),
                        );
                      },
                    ),
                  ),
                ),

                /// RESULT
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),

                const SizedBox(height: 10),

                /// CONTROL
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: betCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Tiền cược',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                isPlaying ? null : () => play('Lower'),
                            child: const Text('LOWER'),
                          ),
                          ElevatedButton(
                            onPressed:
                                isPlaying ? null : () => play('Higher'),
                            child: const Text('HIGHER'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

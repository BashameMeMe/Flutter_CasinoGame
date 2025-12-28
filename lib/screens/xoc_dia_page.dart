import 'dart:math';
import 'package:flutter/material.dart';
import '../core/auth_service.dart';

class XocDiaPage extends StatefulWidget {
  const XocDiaPage({super.key});

  @override
  State<XocDiaPage> createState() => _XocDiaPageState();
}

class _XocDiaPageState extends State<XocDiaPage>
    with SingleTickerProviderStateMixin {
  final auth = AuthService();
  final betCtrl = TextEditingController(text: '100');

  late AnimationController _controller;
  late Animation<double> _scale;

  String choice = 'Chẵn';
  String message = '';
  bool opened = false;
  bool isPlaying = false;
  List<String> result = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = Tween(begin: 1.0, end: 0.0)
        .chain(CurveTween(curve: Curves.easeInOutBack))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    betCtrl.dispose();
    super.dispose();
  }

  List<String> randomXocDia() {
    final rnd = Random();
    return List.generate(4, (_) => rnd.nextBool() ? 'Đỏ' : 'Trắng');
  }

  Future<void> play() async {
    if (isPlaying) return;

    final bet = int.tryParse(betCtrl.text) ?? 0;
    if (bet <= 0) return;

    // ✅ kiểm tra đủ tiền
    if (!await auth.canBet(bet)) {
      setState(() => message = '❌ Không đủ tiền');
      return;
    }

    setState(() {
      isPlaying = true;
      opened = false;
      message = '';
    });

    // 🔻 trừ tiền trước
    await auth.changeBalance(-bet);

    await _controller.forward(from: 0);

    result = randomXocDia();
    final red = result.where((e) => e == 'Đỏ').length;
    final kq = red % 2 == 0 ? 'Chẵn' : 'Lẻ';

    if (kq == choice) {
      await auth.changeBalance(bet * 2);
      message = '🎉 THẮNG';
    } else {
      message = '💥 THUA';
    }

    setState(() {
      opened = true;
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                        'XÓC ĐĨA',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// SÂN KHẤU
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: opened ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Wrap(
                            spacing: 14,
                            children: result.map((e) {
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: e == 'Đỏ'
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _scale,
                          builder: (_, child) => Transform.scale(
                            scale: _scale.value,
                            child: child,
                          ),
                          child: Container(
                            width: size.width * 0.45,
                            height: size.width * 0.45,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['Chẵn', 'Lẻ'].map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      TextField(
                        controller: betCtrl,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Tiền cược',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: isPlaying ? null : play,
                        child: isPlaying
                            ? const CircularProgressIndicator()
                            : const Text('XÓC'),
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

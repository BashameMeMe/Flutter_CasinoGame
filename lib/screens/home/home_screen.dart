import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/wallet_service.dart';
import '../../widgets/game_card.dart';

import '../games/taixiu_screen.dart';
import '../games/xocdia_screen.dart';
import '../games/higher_lower_screen.dart';
import '../games/coin_flip_screen.dart';
import '../games/black_jack_screen.dart';
import '../games/slot_machine_screen.dart';
import '../games/dice_roll_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  int cooldown = 0;
  bool isLocked = false;

  /// ⏱ Đếm 5s rồi cộng coin
  void addCoinAndCooldown() async {
    if (isLocked) return;

    final ok = await WalletService.addPoint(1000);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("💰 Đã cộng 1000 coin")));
    }

    setState(() {
      isLocked = true;
      cooldown = 1;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldown > 1) {
        setState(() => cooldown--);
      } else {
        timer.cancel();
        setState(() {
          cooldown = 0;
          isLocked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini Game Hub"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 💰 COIN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  StreamBuilder<int>(
                    stream: WalletService.pointStream(),
                    builder: (context, snapshot) {
                      return Text(
                        "💰 Coin: ${snapshot.data ?? 0}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLocked ? null : addCoinAndCooldown,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLocked ? Colors.grey : Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      isLocked ? "Đợi $cooldown s..." : "+1000 Coin",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🎮 GAME LIST
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  GameCard(
                    title: "Tài Xỉu",
                    icon: Icons.casino,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TaiXiuScreen()),
                      );
                    },
                  ),
                  GameCard(
                    title: "Xóc Đĩa",
                    icon: Icons.circle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => XocDiaCasinoScreen()),
                      );
                    },
                  ),
                  GameCard(
                    title: "Higher / Lower",
                    icon: Icons.trending_up,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HigherLowerCardScreen()),
                      );
                    },
                  ),
                  
                  GameCard(
                    title: "Dice Roll Casino",
                    icon: Icons.casino,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DiceRollCasinoScreen()),
                      );
                    },
                  ),
                  GameCard(
                    title: "Blackjack",
                    icon: Icons.casino,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BlackjackScreen()),
                      );
                    },
                  ),
                  GameCard(
                    title: "Coin Flip",
                    icon: Icons.casino,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CoinFlipStreakScreen()),
                      );
                    },
                  ),
                  GameCard(
                    title: "Slot Machine",
                    icon: Icons.casino,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SlotMachineScreen()),
                      );
                    },
                  ),
                  GameCard(
                    title: "Coming Soon",
                    icon: Icons.lock,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🚧 Game đang phát triển"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

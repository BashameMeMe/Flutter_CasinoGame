import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/games/roulette_36_screen.dart';
import 'package:flutter_application_1/screens/games/rps_screen.dart';
import '../../services/wallet_service.dart';
import '../games/taixiu_screen.dart';
import '../games/xocdia_screen.dart';
import '../games/higher_lower_screen.dart';
import '../games/coin_flip_screen.dart';
import '../games/slot_machine_screen.dart';
import '../games/dice_roll_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int cooldown = 0;
  bool isLocked = false;

  late AnimationController _animController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  void addCoinAndCooldown() async {
    if (isLocked) return;
    await WalletService.addPoint(1000);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(" +1000 coin!", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.deepPurple.shade800.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(top: 80, right: 20, left: 20),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      isLocked = false;
      cooldown = 3;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldown >= 1) {
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
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      // AppBar với nút nhận coin nhỏ gọn ở bên phải
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.cyanAccent, Colors.purpleAccent],
          ).createShader(bounds),
          child: const Text(
            "MINI GAME HUB",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isLocked
                            ? Colors.grey.withOpacity(0.4)
                            : Colors.cyanAccent.withOpacity(0.6 * _glowAnimation.value),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: isLocked ? null : addCoinAndCooldown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLocked
                                ? [Colors.grey.shade800, Colors.grey.shade900]
                                : [const Color(0xFF00D084), const Color(0xFF00A066)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyanAccent.withOpacity(0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLocked ? Icons.hourglass_bottom_rounded : Icons.bolt,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isLocked ? "$cooldown s" : "1000 FREE",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          // Background gradient nhẹ
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A001A),
                  Color(0xFF140033),
                  Color(0xFF1A003F),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Balance hiển thị nhỏ gọn ở trên cùng
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                    ),
                    child: StreamBuilder<int>(
                      stream: WalletService.pointStream(),
                      builder: (context, snapshot) {
                        final coin = snapshot.data ?? 0;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.diamond_rounded,
                              color: Colors.amberAccent,
                              size: 28,
                              shadows: [Shadow(color: Colors.amber, blurRadius: 8)],
                            ),
                            const SizedBox(width: 10),
                            Text(
                              coin.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (m) => '${m[1]},',
                              ),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 12)],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tiêu đề games - nổi bật
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.purpleAccent, Colors.pinkAccent],
                      ).createShader(bounds),
                      child: const Text(
                        "CHỌN TRÒ CHƠI",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Grid trò chơi - chiếm phần lớn không gian
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.88,
                      children: [
                        _buildGameCard(
                          title: "Tài Xỉu",
                          icon: Icons.casino,
                          color: Colors.redAccent,
                          screen: () => const TaiXiuScreen(),
                        ),
                        _buildGameCard(
                          title: "Xóc Đĩa",
                          icon: Icons.circle_outlined,
                          color: Colors.amberAccent,
                          screen: () => const XocDiaCasinoScreen(),
                        ),
                        _buildGameCard(
                          title: "Cao / Thấp",
                          icon: Icons.trending_up_rounded,
                          color: Colors.cyanAccent,
                          screen: () => const HigherLowerCardScreen(),
                        ),
                        _buildGameCard(
                          title: "Xúc Xắc",
                          icon: Icons.casino_rounded,
                          color: Colors.deepOrangeAccent,
                          screen: () => const DiceRollCasinoScreen(),
                        ),
                        _buildGameCard(
                          title: "Roulette",
                          icon: Icons.style_rounded,
                          color: Colors.purpleAccent,
                          screen: () => const Roulette36Screen(),
                        ),
                        _buildGameCard(
                          title: "Coin Flip",
                          icon: Icons.autorenew_rounded,
                          color: Colors.tealAccent,
                          screen: () => const CoinFlipStreakScreen(),
                        ),
                        _buildGameCard(
                          title: "Slot Machine",
                          icon: Icons.casino_sharp,
                          color: Colors.pinkAccent,
                          screen: () => const SlotMachineScreen(),
                        ),
                        _buildGameCard(
                          title: "✊✋✌️",
                          icon: Icons.handshake,
                          color: Colors.pinkAccent,
                          screen: () => const RPSScreen(),
                        ),
                        _buildGameCard(
                          title: "Sắp Có",
                          icon: Icons.construction_rounded,
                          color: Colors.grey,
                          isComingSoon: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required IconData icon,
    required Color color,
    Widget Function()? screen,
    bool isComingSoon = false,
  }) {
    return GestureDetector(
      onTap: isComingSoon
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Game đang được phát triển 🔥", style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.deepOrange.shade800.withOpacity(0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            }
          : () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen!())),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.7), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.45), blurRadius: 18, spreadRadius: 2),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.25),
              color.withOpacity(0.10),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: color,
              shadows: [
                Shadow(color: color, blurRadius: 20),
                Shadow(color: color.withOpacity(0.7), blurRadius: 40),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
                shadows: [Shadow(color: color.withOpacity(0.8), blurRadius: 10)],
              ),
            ),
            if (isComingSoon) ...[
              const SizedBox(height: 8),
              const Text(
                "SOON",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
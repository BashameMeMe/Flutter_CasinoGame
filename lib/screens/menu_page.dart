import 'package:flutter/material.dart';
import '../core/auth_service.dart';
import 'xoc_dia_page.dart';
import 'higher_lower_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder(
      stream: auth.userStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!.data()!;
        final username = user['username'];
        final balance = user['balance'];

        return Scaffold(
          backgroundColor: const Color(0xFF0B0F1A),
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('🎰 $username'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => auth.logout(),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// BALANCE
                Text(
                  '💰 $balance',
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                /// XÓC ĐĨA
                _menuButton(
                  text: '🎲 XÓC ĐĨA',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const XocDiaPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// HIGHER / LOWER
                _menuButton(
                  text: '🃏 HIGHER / LOWER',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HigherLowerPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 240,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

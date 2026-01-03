import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/wallet_service.dart';

class BlackjackScreen extends StatefulWidget {
  const BlackjackScreen({super.key});

  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  final Random _random = Random();

  List<int> playerCards = [];
  List<int> dealerCards = [];
  bool playing = false;
  int bet = 500;

  int calculateScore(List<int> cards) {
    int score = cards.map((e) => e > 10 ? 10 : e).reduce((a, b) => a + b);
    int aces = cards.where((e) => e == 1).length;
    while (score <= 11 && aces > 0) {
      score += 10;
      aces--;
    }
    return score;
  }

  int drawCard() => _random.nextInt(13) + 1;

  String cardLabel(int value) {
    if (value == 1) return 'A';
    if (value == 11) return 'J';
    if (value == 12) return 'Q';
    if (value == 13) return 'K';
    return value.toString();
  }

  Widget cardWidget(int value, {bool hidden = false}) {
    final isRed = value == 1 || value == 11 || value == 12 || value == 13;
    final label = hidden ? '?' : cardLabel(value);

    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[700]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: hidden ? 50 : 48,
                fontWeight: FontWeight.bold,
                color: isRed ? Colors.red[800] : Colors.black87,
                shadows: const [Shadow(blurRadius: 4, color: Colors.black45)],
              ),
            ),
          ),
          if (!hidden)
            Positioned(
              top: 8,
              left: 8,
              child: Text(
                isRed ? '♥' : '♠',
                style: TextStyle(
                  fontSize: 20,
                  color: isRed ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> startGame() async {
    final ok = await WalletService.deductPoint(bet);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không đủ coin")),
      );
      return;
    }

    setState(() {
      playerCards = [drawCard(), drawCard()];
      dealerCards = [drawCard()];
      playing = true;
    });
  }

  void hit() {
    setState(() {
      playerCards.add(drawCard());
    });

    if (calculateScore(playerCards) > 21) {
      endGame(false);
    }
  }

  void stand() async {
    while (calculateScore(dealerCards) < 17) {
      dealerCards.add(drawCard());
    }

    final playerScore = calculateScore(playerCards);
    final dealerScore = calculateScore(dealerCards);

    final win = playerScore <= 21 && (dealerScore > 21 || playerScore > dealerScore);
    endGame(win);
  }

  Future<void> endGame(bool win) async {
    if (win) {
      await WalletService.addPoint(bet * 2);
    }

    setState(() => playing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: win ? Colors.green[700] : Colors.red[800],
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(win ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              win ? "🎉 THẮNG ${bet * 2} coin!" : "💥 THUA",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget handSection(String title, List<int> cards, {bool isDealer = false}) {
    final score = calculateScore(cards);
    final visibleCards = isDealer && playing ? [cards.first, ...List.filled(cards.length - 1, 0)] : cards;

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: visibleCards.map((val) => cardWidget(val, hidden: val == 0)).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          "Score: $score",
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("BLACKJACK VIP", style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A3A),
              Color(0xFF2A1B4A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Dealer hand
                  handSection("DEALER", dealerCards, isDealer: true),

                  const Spacer(),

                  // Player hand
                  handSection("YOU", playerCards),

                  const SizedBox(height: 40),

                  if (!playing)
                    GestureDetector(
                      onTap: startGame,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Text(
                          "BẮT ĐẦU – 500 coin",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                  if (playing) ...[
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: hit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                          ),
                          child: const Text(
                            "HIT",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: stand,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                          ),
                          child: const Text(
                            "STAND",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
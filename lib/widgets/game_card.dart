import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const GameCard({required this.title, required this.onTap, required IconData icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(title, style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

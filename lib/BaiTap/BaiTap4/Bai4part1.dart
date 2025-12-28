import 'package:flutter/material.dart';
import 'dart:math';

class ChangeColorApp extends StatefulWidget {
  const ChangeColorApp({super.key});

  @override
  State<ChangeColorApp> createState() => _ChangeColorAppState();
}

class _ChangeColorAppState extends State<ChangeColorApp> {
  Color bgColor = Colors.purple;
  String colorName = "Tím";

  // Danh sách các màu và tên tương ứng
  final List<Map<String, dynamic>> colors = [
    {"color": Colors.red, "name": "Đỏ"},
    {"color": Colors.green, "name": "Xanh lá"},
    {"color": Colors.blue, "name": "Xanh dương"},
    {"color": Colors.orange, "name": "Cam"},
    {"color": Colors.purple, "name": "Tím"},
    {"color": Colors.yellow, "name": "Vàng"},
    {"color": Colors.pink, "name": "Hồng"},
    {"color": Colors.teal, "name": "Xanh ngọc"},
  ];

  void changeColor() {
    final random = Random();
    int index = random.nextInt(colors.length);
    setState(() {
      bgColor = colors[index]["color"];
      colorName = colors[index]["name"];
    });
  }

  void resetColor() {
    setState(() {
      bgColor = Colors.white;
      colorName = "Trắng";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ứng dụng Đổi màu nền",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Màu hiện tại",
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                colorName,
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: changeColor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Đổi màu"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: resetColor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Cài lại"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

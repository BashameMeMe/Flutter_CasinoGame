import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int count = 0;

  // Hàm lấy màu chữ theo giá trị
  Color getTextColor() {
    if (count > 0) return Colors.green;
    if (count < 0) return Colors.red;
    return Colors.black;
  }

  void increase() {
    setState(() {
      count++;
    });
  }

  void decrease() {
    setState(() {
      count--;
    });
  }

  void reset() {
    setState(() {
      count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ứng dụng Đếm Số",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Giá trị hiện tại:",
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: getTextColor(),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: decrease,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("- Giảm"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Đặt lại"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: increase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("+ Tăng"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

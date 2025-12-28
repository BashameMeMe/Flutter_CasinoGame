import 'package:flutter/material.dart';

class BMIPage extends StatefulWidget {
  const BMIPage({super.key});

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  double? bmi;
  String? category;

  void tinhBMI() {
    double h = double.tryParse(heightController.text) ?? 0;
    double w = double.tryParse(weightController.text) ?? 0;

    if (h <= 0 || w <= 0) {
      setState(() {
        bmi = null;
        category = "Dữ liệu không hợp lệ";
      });
      return;
    }

    double result = w / (h * h);
    String loai;

    if (result < 18.5) loai = "Thiếu cân";
    else if (result < 25) loai = "Bình thường";
    else if (result < 30) loai = "Thừa cân";
    else loai = "Béo phì";

    setState(() {
      bmi = result;
      category = loai;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.green, // màu xanh lá
  title: const Text(
    "Tính chỉ số BMI",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: true,
),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chiều cao (m)"),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ví dụ: 1.7",
              ),
            ),
            const SizedBox(height: 20),

            const Text("Cân nặng (kg)"),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ví dụ: 60",
              ),
            ),
            const SizedBox(height: 25),

            Center(
              child: ElevatedButton(
                onPressed: tinhBMI,
                child: const Text("Tính BMI"),
              ),
            ),

            const SizedBox(height: 20),

            if (bmi != null) ...[
              Text(
                "Chỉ số BMI: ${bmi!.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(
                "Phân loại: $category",
                style: const TextStyle(fontSize: 20, color: Colors.red),
              )
            ]
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  int selectedStars = 4;

  void submitFeedback() {
    String name = nameController.text;
    String content = contentController.text;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cảm ơn!"),
        content: Text(
          "Cảm ơn $name đã đánh giá $selectedStars sao với nội dung: \n\n$content",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              color: Colors.orange,
              child: const Text(
                "Gửi phản hồi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // INPUT HỌ TÊN
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: "Họ tên",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // DROPDOWN ĐÁNH GIÁ SAO
            DropdownButtonFormField<int>(
              value: selectedStars,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.star),
                labelText: "Đánh giá (1 - 5 sao)",
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                5,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text("${index + 1} sao"),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedStars = value ?? 4;
                });
              },
            ),
            const SizedBox(height: 20),

            // NỘI DUNG GÓP Ý
            Row(
              children: const [
                
              ],
            ),const SizedBox(height: 8),

            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Nội dung góp ý",
                border: OutlineInputBorder(),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.message),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON GỬI PHẢN HỒI
            Row(
              children: const [
                
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: submitFeedback,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Gửi phản hồi",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
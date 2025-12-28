import 'package:flutter/material.dart';
import 'package:flutter_application_1/BaiTap/BaiTap9/Bai9part1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String accessToken;
  final String refreshToken;

  const ProfilePage({
    super.key,
    required this.userData,
    required this.accessToken,
    required this.refreshToken,
  });

  // Row hiển thị 1 dòng thông tin
  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? "N/A"),
          ),
        ],
      ),
    );
  }

  // Section có tiêu đề
  Widget section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + username
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: NetworkImage(
                      userData["image"] ??
                          "https://via.placeholder.com/150",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData["username"] ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Personal Info
            section("Personal Information", [
              infoRow("ID", userData["id"]),
              infoRow("First Name", userData["firstName"]),
              infoRow("Last Name", userData["lastName"]),
              infoRow("Age", userData["age"]),
              infoRow("Gender", userData["gender"]),
              infoRow("Birth Date", userData["birthDate"]),
              infoRow("Email", userData["email"]),
              infoRow("Phone", userData["phone"]),
            ]),

            // Hair
            section("Hair", [
              infoRow("Color", userData["hair"]?["color"]),
              infoRow("Type", userData["hair"]?["type"]),
            ]),

            // Address
            section("Address", [
              infoRow("City", userData["address"]?["city"]),
              infoRow("Country", userData["address"]?["country"]),
              infoRow("Address", userData["address"]?["address"]),
            ]),
          ],
        ),
      ),
    );
  }
}

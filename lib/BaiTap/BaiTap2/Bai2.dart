import 'package:flutter/material.dart';

void main() {
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<String> images = const [
    'lib/BaiTap/BaiTap2/p1.png',
    'lib/BaiTap/BaiTap2/p2.png',
    'lib/BaiTap/BaiTap2/p3.png',
    'lib/BaiTap/BaiTap2/p4.png',
  ];

  final List<String> places = const [
    'Paris',
    'Tokyo',
    'New York',
    'Rome',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔔 Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.notifications_none),
                  SizedBox(width: 8),
                  Icon(Icons.extension_outlined),
                ],
              ),

              const SizedBox(height: 24),

              // 👋 Welcome
              const Text(
                'Welcome,\nCharlie',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 24),

              // 🔍 Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.blue),
                    hintText: 'Search places',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // 📍 Section title
              const Text(
                'Saved Places',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // 🖼️ Grid
              Expanded(
                child: GridView.builder(
                  itemCount: images.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            // 🖼️ Image
                            Positioned.fill(
                              child: Image.asset(
                                images[index],
                                fit: BoxFit.cover,
                              ),
                            ),

                            // 🌈 Gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.65),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 📍 Place name
                            Positioned(
                              left: 14,
                              bottom: 14,
                              child: Text(
                                places[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

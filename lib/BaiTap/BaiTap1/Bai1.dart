
// Khởi tạo ứng dụng Flutter
import 'package:flutter/material.dart';

void main() {
  runApp(const CourseApp());
}

class CourseApp extends StatelessWidget {
  const CourseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course List UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Đặt font chữ chung nếu cần
      ),
      home: CourseListScreen(),
    );
  }
}

// Model dữ liệu cho mỗi khóa học
class Course {
  final String title;
  final String code;
  final String studentCount;
  final Color backgroundColor;
  final Widget backgroundIcon; // Dùng Widget để linh hoạt về biểu tượng

  Course({
    required this.title,
    required this.code,
    required this.studentCount,
    required this.backgroundColor,
    required this.backgroundIcon,
  });
}

// Màn hình hiển thị danh sách khóa học
class CourseListScreen extends StatelessWidget {
  CourseListScreen({super.key});

  // Dữ liệu mẫu (tương tự như trong hình)
  final List<Course> courses = [
    Course(
      title: 'XML và ứng dụng - Nhóm 1',
      code: '2025-2026.1.TIN4583.001',
      studentCount: '58 học viên',
      backgroundColor: Color(0xFF424242), // Màu nền tối cho thẻ đầu tiên
      backgroundIcon: Icon(Icons.star, color: Colors.yellow, size: 100), // Ví dụ huy chương
    ),
    Course(
      title: 'Lập trình ứng dụng cho các t...',
      code: '2025-2026.1.TIN4403.006',
      studentCount: '55 học viên',
      backgroundColor:  Color(0xFF424242), // Màu nền đỏ
      backgroundIcon: Icon(Icons.book, color: Colors.white, size: 100), // Ví dụ sách
    ),
    Course(
      title: 'Lập trình ứng dụng cho các t...',
      code: '2025-2026.1.TIN4403.005',
      studentCount: '52 học viên',
      backgroundColor:  Color(0xFF424242), // Màu nền đỏ
      backgroundIcon: Icon(Icons.book, color: Colors.white, size: 100),
    ),
    Course(
      title: 'Lập trình ứng dụng cho các t...',
      code: '2025-2026.1.TIN4403.004',
      studentCount: '50 học viên',
      backgroundColor:  Color(0xFF424242), // Màu nền xanh dương
      backgroundIcon: Icon(Icons.school, color: Colors.white, size: 100), // Ví dụ mũ tốt nghiệp
    ),
    Course(
      title: 'Lập trình ứng dụng cho các t...',
      code: '2025-2026.1.TIN4403.003',
      studentCount: '52 học viên',
      backgroundColor: Color(0xFF424242), // Màu nền tối
      backgroundIcon: Icon(Icons.star, color: Colors.yellow, size: 100),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Khóa học'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return CourseCard(course: courses[index]);
        },
      ),
    );
  }
}

// Widget tùy chỉnh cho mỗi thẻ Khóa học
class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Stack để đặt biểu tượng (hình nền) phía sau nội dung
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Container(
        height: 150, // Chiều cao cố định cho mỗi thẻ
        decoration: BoxDecoration(
          color: course.backgroundColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          children: [
            // 1. Biểu tượng/Hình nền (Background Icon) - Đặt ở phía sau
            Positioned(
              right: -30,
              bottom: -30,
              child: Opacity(
                opacity: 0.2, // Giảm độ mờ để làm hình nền
                child: course.backgroundIcon,
              ),
            ),
            // 2. Nội dung khóa học (Foreground Content)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tiêu đề và nút ba chấm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  // Mã khóa học và Số lượng học viên
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.code,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.studentCount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
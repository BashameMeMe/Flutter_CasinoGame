import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> hotels = const [
  {
    'name': 'aNhill Boutique',
    'rating': 9.5,
    'reviews': 95,
    'comment': 'Xuất sắc',
    'location': 'Huế - Cách bạn 0,6km',
    'room': '1 suite riêng tư: 1 giường',
    'price': 'US\$109',
    'image': 'lib/BaiTap/BaiTap3/baitap3-p1.png',
    'note': 'Đã bao gồm thuế và phí',
    'breakfast': true
  },
  {
    'name': 'An Nam Hue Boutique',
    'rating': 9.2,
    'reviews': 34,
    'comment': 'Tuyệt hảo',
    'location': 'Cự Chính - Cách bạn 0,9km',
    'room': '1 phòng khách sạn: 1 giường',
    'price': 'US\$20',
    'image': 'lib/BaiTap/BaiTap3/baitap3-p2.png',
    'note': 'Đã bao gồm thuế và phí',
    'breakfast': true
  },
  {
    'name': 'Huế Jade Hill Villa',
    'rating': 8.0,
    'reviews': 21,
    'comment': 'Rất tốt',
    'location': 'Cự Chính - Cách bạn 1,3km',
    'room':
        '1 biệt thự nguyên căn – 1.000 m² · 4 giường · 3 phòng ngủ · 3 phòng tắm',
    'price': 'US\$285',
    'image': 'lib/BaiTap/BaiTap3/baitap3-p3.png',
    'note':
        'Chỉ còn 1 căn với giá này trên Booking.com\nKhông cần thanh toán trước',
    'breakfast': true
  },
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            const Divider(height: 1),
            Expanded(child: _buildHotelList(context)),
          ],
        ),
      ),
    );
  }

  // Header màu xanh
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: Colors.blue[700], //  nền xanh đậm
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Xung quanh vị trí hiện tại",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  "23 thg 10 – 24 thg 10",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  Thanh lọc
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _FilterButton(icon: Icons.sort, label: "Sắp xếp"),
          _FilterButton(icon: Icons.filter_alt_outlined, label: "Lọc"),
          _FilterButton(icon: Icons.map_outlined, label: "Bản đồ"),
        ],
      ),
    );
  }

  //  Danh sách khách sạn
  Widget _buildHotelList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        return _buildHotelRow(context, hotels[index]);
      },
    );
  }

  // 🟥 Item khách sạn (ảnh bên trái, chữ bên phải)
  Widget _buildHotelRow(BuildContext context, Map<String, dynamic> hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ Ảnh bên trái
          Flexible(
            flex: 4,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildImage(hotel['image']),
                  ),
                ),
                if (hotel['breakfast'])
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Bao bữa sáng',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 📋 Thông tin bên phải
          Flexible(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingRow(hotel),
                const SizedBox(height: 3),
                Text(
                  hotel['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hotel['location'],
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hotel['room'],
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  hotel['price'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  hotel['note'],
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ Rating
  Widget _buildRatingRow(Map<String, dynamic> hotel) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            hotel['rating'].toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "${hotel['comment']} · ${hotel['reviews']} đánh giá",
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 🖼️ Xử lý ảnh
  Widget _buildImage(String imagePath) {
    return Image(
      image: imagePath.startsWith('http')
          ? NetworkImage(imagePath)
          : AssetImage(imagePath) as ImageProvider,
      fit: BoxFit.cover,
    );
  }
}

// 🟧 Nút lọc
class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FilterButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

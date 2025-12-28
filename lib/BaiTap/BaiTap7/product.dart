class Product {
  int id; String title;String decription; String image;
  dynamic price; String category;
  Product({
    required this.id,
    required this.title,
    required this.decription,
    required this.image,
    required this.price,
    required this.category,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
   return Product(id:json['id'] ?? 0, 
                  title: json['title']??'', 
                  decription: json['description']??'',
                  image: json['image']??'', 
                  price: json['price'] ?? 0, 
                  category: json['category'] ?? '');
    
    

  }
}
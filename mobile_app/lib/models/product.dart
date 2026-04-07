class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final DateTime createdAt;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

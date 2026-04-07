import 'product.dart';

class Order {
  const Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.customerName,
    required this.customerPhone,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final String customerName;
  final String customerPhone;
  final DateTime createdAt;
  final List<OrderItem> items;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'] as String,
      shippingAddress: json['shipping_address'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.product,
  });

  final int id;
  final int productId;
  final int quantity;
  final double unitPrice;
  final Product product;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }
}

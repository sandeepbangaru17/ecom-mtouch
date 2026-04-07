import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

class ApiClient {
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$_baseUrl$path').replace(
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _post('/auth/login', body: {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<ProductsResponse> getProducts({
    String search = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await http.get(
      _buildUri('/products', {
        'search': search,
        'page': page,
        'page_size': pageSize,
      }),
    );
    final data = _decodeResponse(response);
    return ProductsResponse(
      items: (data['items'] as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['page_size'] as int,
    );
  }

  Future<List<Order>> getOrders(String token) async {
    final response = await http.get(
      _buildUri('/orders'),
      headers: _headers(token),
    );
    final data = _decodeResponse(response);
    return (data['items'] as List<dynamic>)
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> placeOrder({
    required String token,
    required List<CartItem> items,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
  }) async {
    return _post(
      '/orders',
      token: token,
      body: {
        'items': items
            .map(
              (item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
              },
            )
            .toList(),
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'shipping_address': shippingAddress,
        'payment_method': 'cod',
      },
    );
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final response = await http.post(
      _buildUri(path),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(data['detail'] ?? 'Request failed.');
    }
    return data;
  }
}

class ProductsResponse {
  const ProductsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<Product> items;
  final int total;
  final int page;
  final int pageSize;
}

import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/api_client.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._apiClient);

  final ApiClient _apiClient;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _apiClient.getOrders(token);
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder({
    required String token,
    required List<CartItem> items,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.placeOrder(
        token: token,
        items: items,
        customerName: customerName,
        customerPhone: customerPhone,
        shippingAddress: shippingAddress,
      );
      await fetchOrders(token);
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

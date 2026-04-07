import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_client.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._apiClient);

  final ApiClient _apiClient;

  List<Product> _products = [];
  bool _isLoading = false;
  String _query = '';
  int _page = 1;
  int _pageSize = 10;
  int _total = 0;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  int get page => _page;
  int get total => _total;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => (_page * _pageSize) < _total;

  Future<void> fetchProducts({String? query, int? page}) async {
    _isLoading = true;
    _errorMessage = null;
    if (query != null) {
      _query = query;
    }
    if (page != null) {
      _page = page;
    }
    notifyListeners();

    try {
      final response = await _apiClient.getProducts(
        search: _query,
        page: _page,
        pageSize: _pageSize,
      );
      _products = response.items;
      _total = response.total;
      _page = response.page;
      _pageSize = response.pageSize;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

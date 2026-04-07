import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopFlow'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const CartScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().fetchProducts(
              query: _searchController.text.trim(),
              page: products.page,
            ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => context.read<ProductProvider>().fetchProducts(
                        query: _searchController.text.trim(),
                        page: 1,
                      ),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              onSubmitted: (value) {
                context.read<ProductProvider>().fetchProducts(query: value, page: 1);
              },
            ),
            const SizedBox(height: 20),
            if (products.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (products.errorMessage != null)
              Text(
                products.errorMessage!,
                style: const TextStyle(color: Colors.red),
              )
            else if (products.products.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: Text('No products found.')),
              )
            else
              ...products.products.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child: Image.network(
                              product.imageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                height: 220,
                                child: ColoredBox(color: Color(0xFFD9E3F0)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rs ${product.price.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        context.read<CartProvider>().addToCart(product);
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: products.page > 1 && !products.isLoading
                        ? () => context.read<ProductProvider>().fetchProducts(
                              query: _searchController.text.trim(),
                              page: products.page - 1,
                            )
                        : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Page ${products.page}'),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: products.hasNextPage && !products.isLoading
                        ? () => context.read<ProductProvider>().fetchProducts(
                              query: _searchController.text.trim(),
                              page: products.page + 1,
                            )
                        : null,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

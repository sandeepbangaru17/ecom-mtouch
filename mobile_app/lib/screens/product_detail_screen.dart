import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFD9E3F0),
                  child: Center(child: Icon(Icons.image_not_supported_outlined)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            product.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Rs ${product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(product.description),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () {
              context.read<CartProvider>().addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to cart')),
              );
            },
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('Add to cart'),
          ),
        ),
      ),
    );
  }
}

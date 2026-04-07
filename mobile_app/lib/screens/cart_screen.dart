import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const ColoredBox(
                                color: Color(0xFFD9E3F0),
                                child: SizedBox(width: 56, height: 56),
                              ),
                            ),
                          ),
                          title: Text(item.product.name),
                          subtitle: Text('Rs ${item.total.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => cart.decrement(item.product.id),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                onPressed: () => cart.increment(item.product.id),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: cart.items.length,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Color(0x11000000), blurRadius: 18),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: Rs ${cart.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );
                          },
                          child: const Text('Proceed to Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

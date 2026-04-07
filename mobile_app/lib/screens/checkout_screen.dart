import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Cash on Delivery only',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) => (value == null || value.trim().length < 2)
                  ? 'Enter a valid name'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone number'),
              keyboardType: TextInputType.phone,
              validator: (value) => (value == null || value.trim().length < 8)
                  ? 'Enter a valid phone number'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Shipping address'),
              minLines: 3,
              maxLines: 5,
              validator: (value) => (value == null || value.trim().length < 10)
                  ? 'Enter the full delivery address'
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Order total: Rs ${cart.totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: orders.isLoading
                  ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        final orderProvider = context.read<OrderProvider>();
                        final cartProvider = context.read<CartProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final token = auth.token;
                        if (token == null) {
                          return;
                        }
                        final success = await orderProvider.placeOrder(
                              token: token,
                              items: cart.items,
                              customerName: _nameController.text.trim(),
                              customerPhone: _phoneController.text.trim(),
                              shippingAddress: _addressController.text.trim(),
                          );
                        if (!mounted) {
                          return;
                        }
                        if (success) {
                          cartProvider.clear();
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Order placed successfully.')),
                          );
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                              builder: (_) => const OrdersScreen(),
                            ),
                            (route) => route.isFirst,
                          );
                      }
                    },
              child: orders.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Place COD Order'),
            ),
            if (orders.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                orders.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

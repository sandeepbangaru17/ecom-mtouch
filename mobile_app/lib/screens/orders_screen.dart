import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<OrderProvider>().fetchOrders(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.orders.isEmpty
              ? const Center(child: Text('No orders yet.'))
              : RefreshIndicator(
                  onRefresh: () async {
                    final token = context.read<AuthProvider>().token;
                    if (token != null) {
                      await context.read<OrderProvider>().fetchOrders(token);
                    }
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final order = orders.orders[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${order.id}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Chip(label: Text(order.status)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(formatter.format(order.createdAt.toLocal())),
                              const SizedBox(height: 8),
                              ...order.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text('${item.product.name} x ${item.quantity}'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Total: Rs ${order.totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(order.shippingAddress),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: orders.orders.length,
                  ),
                ),
    );
  }
}

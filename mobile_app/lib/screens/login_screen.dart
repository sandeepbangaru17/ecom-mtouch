import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ShopFlow',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Login to continue shopping with Cash on Delivery.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) => (value == null || !value.contains('@'))
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (value) => (value == null || value.length < 6)
                              ? 'Minimum 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  await context.read<AuthProvider>().login(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                      );
                                },
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Login'),
                        ),
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

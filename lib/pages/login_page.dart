import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/providers/auth_provider.dart';
import 'package:prototype_a/providers/index_provider.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(WidgetRef ref, BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // only change index if login succeeded
      final authState = ref.read(authControllerProvider);
      if (authState.hasValue && authState.value != null) {
        ref.read(currentIndexProvider.notifier).setIndex(0);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 300,
          child: authState.when(
            data: (user) {
              // If already logged in → redirect or show message
              if (user != null) {
                return const Center(child: Text("Already logged in"));
              }

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Welcome to the Login Page"),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Email"),
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Enter email"
                          : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Enter password"
                          : null,
                      onFieldSubmitted: (_) => _login(ref, context),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _login(ref, context),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) {
              // Must return a widget
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $err')));
              });
              return const Center(child: Text("Login failed"));
            },
          ),
        ),
      ),
    );
  }
}

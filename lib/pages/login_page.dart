import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/providers/auth_provider.dart';
import 'package:prototype_a/providers/index_provider.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      ref.read(currentIndexProvider.notifier).setIndex(0);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Welcome to the Login Page"),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Email"),
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) => _login(ref),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _login(ref),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

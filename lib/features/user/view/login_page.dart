import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/user/view/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: const LoginForm(),
        ),
      ),
    );
  }
}

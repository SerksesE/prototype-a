import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/auth/providers/auth_controller.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated error message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: authState.hasError
                ? Container(
                    key: ValueKey(authState.error),
                    color: Colors.red[300],
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .clearError(),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),

          // Email & password fields
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: "Email"),
            textInputAction: TextInputAction.next,
            validator: (value) =>
                (value == null || value.isEmpty) ? "Enter email" : null,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                (value == null || value.isEmpty) ? "Enter password" : null,
            onFieldSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _login,
            child: authState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Login"),
          ),
        ],
      ),
    );
  }
}

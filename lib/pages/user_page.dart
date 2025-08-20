import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/providers/auth_provider.dart';
import 'package:prototype_a/providers/user_provider.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Welcome ${user.value?.email}")),
      body: Center(
        child: TextButton(
          onPressed: () => ref.watch(authControllerProvider.notifier).signOut(),
          child: const Text("Logout"),
        ),
      ),
    );
  }
}

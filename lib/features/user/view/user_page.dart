import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/admin/view/admin_section.dart';
import 'package:prototype_a/features/user/providers/user_controller.dart';
import 'package:prototype_a/features/user/view/password_section.dart';
import 'package:prototype_a/features/user/view/profile_section.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userControllerProvider).currentUser;

    return userAsync.when(
      data: (user) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: kIsWeb ? 600 : double.infinity,
                maxWidth: kIsWeb ? 600 : double.infinity,
              ),
              child: Column(
                children: [
                  const ProfileSection(),
                  const SizedBox(height: 16),
                  const PasswordSection(),
                  const SizedBox(height: 16),
                  if (user?.isAdmin ?? false)
                    SizedBox(
                      width: double.infinity,
                      child: const AdminSection(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }
}

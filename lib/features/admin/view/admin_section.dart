import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/admin/providers/admin_controller.dart';
import 'package:prototype_a/features/user/data/user_model.dart';
import 'package:prototype_a/features/user/providers/user_controller.dart';

class AdminSection extends ConsumerWidget {
  const AdminSection({super.key});

  void _toggleUserVisibility(
    UserModel user,
    WidgetRef ref,
    UserModel? selectedUser,
  ) {
    if (user == selectedUser) {
      ref.read(userControllerProvider.notifier).clearSelectedUser();
    } else {
      ref.read(userControllerProvider.notifier).selectUser(user);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsync = ref.watch(adminControllerProvider);

    return allUsersAsync.when(
      data: (users) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (_, index) {
              final user = users[index];

              // Only watch selectedUser per row to avoid full rebuild
              return Consumer(
                builder: (context, ref, _) {
                  final selectedUser = ref.watch(
                    userControllerProvider.select((s) => s.selectedUser),
                  );

                  final isSelected = selectedUser == user;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(user.firstName ?? ''),
                      Text(user.lastName ?? ''),
                      Text(user.email ?? ''),
                      IconButton(
                        icon: Icon(
                          isSelected ? Icons.visibility : Icons.visibility_off,
                        ),
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            isSelected ? Colors.blue : Colors.grey,
                          ),
                        ),
                        onPressed: () =>
                            _toggleUserVisibility(user, ref, selectedUser),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

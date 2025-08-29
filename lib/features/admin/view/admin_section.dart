import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/admin/providers/admin_controller.dart';
import 'package:prototype_a/features/auth/providers/auth_controller.dart';
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

  Future<void> _registerUser(
    WidgetRef ref,
    String email,
    BuildContext context,
  ) async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .registerUserByEmail(email);

      // refresh users
      await ref.read(adminControllerProvider.notifier).refreshUsers();

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _openRegisterModal(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final authState = ref.watch(authControllerProvider);

            return AlertDialog(
              title: const Text("Register User"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () =>
                      _registerUser(ref, emailController.text.trim(), context),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Register"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsync = ref.watch(adminControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [_buildUserList(context, ref, allUsersAsync)]),
      ),
    );
  }

  Widget _buildUserList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<UserModel>> allUsersAsync,
  ) {
    return allUsersAsync.when(
      data: (users) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Users", style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () => _openRegisterModal(context, ref),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ListView.separated(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (_, index) {
              final user = users[index];

              // Only watch selectedUser per row to avoid full rebuild
              return Consumer(
                builder: (context, ref, _) {
                  final selectedUser = ref
                      .watch(userControllerProvider)
                      .selectedUser;

                  final isSelected = selectedUser == user;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${user.firstName ?? ''} ${user.lastName ?? ''}',
                    ),
                    subtitle: Text(user.email ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.isAdmin == true)
                          const Text(
                            "Admin",
                            style: TextStyle(color: Colors.red),
                          ),
                        IconButton(
                          icon: Icon(
                            isSelected
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () =>
                              _toggleUserVisibility(user, ref, selectedUser),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, _) => const Divider(height: 1),
          ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

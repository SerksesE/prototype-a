import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/admin/providers/admin_controller.dart';
import 'package:prototype_a/features/admin/providers/admin_state.dart';
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

      if (!context.mounted) return;

      Navigator.of(context).pop();

      // refresh users
      await ref
          .read(adminControllerProvider.notifier)
          .refreshUsersIncremental();
    } catch (e) {
      if (!context.mounted) return;

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
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
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

  Future<void> _deleteUser(
    WidgetRef ref,
    UserModel user,
    BuildContext context,
  ) async {
    try {
      await ref.read(adminControllerProvider.notifier).deleteUser(user.id!);

      if (!context.mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _openDeleteModal(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final adminState = ref.watch(adminControllerProvider);

            return AlertDialog(
              title: const Text("Delete User"),
              content: Text("Are you sure you want to delete ${user.email}?"),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => _deleteUser(ref, user, context),
                  child: adminState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Delete"),
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
    final adminState = ref.watch(adminControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [_buildUserList(context, ref, adminState)]),
      ),
    );
  }

  Widget _buildUserList(
    BuildContext context,
    WidgetRef ref,
    AdminState adminState,
  ) {
    return adminState.users.when(
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

                  final isLoading = ref.watch(
                    adminControllerProvider.select(
                      (s) => s.loadingUserIds.contains(user!.id),
                    ),
                  );

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${user!.firstName ?? ''} ${user.lastName ?? ''}',
                    ),
                    subtitle: Text(user.email ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        IconButton(
                          icon: isLoading
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey,
                                    ),
                                  ),
                                )
                              : Icon(
                                  user.isAdmin!
                                      ? Icons.verified_user
                                      : Icons.add_moderator_outlined,
                                  color: user.isAdmin!
                                      ? Colors.green[300]
                                      : Colors.black45,
                                ),
                          onPressed: isLoading
                              ? null
                              : () => user.isAdmin!
                                    ? ref
                                          .read(
                                            adminControllerProvider.notifier,
                                          )
                                          .removeAdminUser(user.id!)
                                    : ref
                                          .read(
                                            adminControllerProvider.notifier,
                                          )
                                          .addAdminUser(user.id!, user.email!),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.red[300],
                          ),
                          onPressed: () => _openDeleteModal(context, ref, user),
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

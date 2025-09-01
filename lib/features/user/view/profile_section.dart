import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/user/providers/user_controller.dart';

class ProfileSection extends ConsumerStatefulWidget {
  const ProfileSection({super.key});

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;

  bool hasChanges = false;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();

    firstNameController.addListener(_updateHasChanges);
    lastNameController.addListener(_updateHasChanges);
    emailController.addListener(_updateHasChanges);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _updateHasChanges() {
    final user =
        ref.read(userControllerProvider).selectedUser ??
        ref.read(userControllerProvider).currentUser.value;

    if (user == null) return;

    setState(() {
      hasChanges =
          firstNameController.text != user.firstName ||
          lastNameController.text != user.lastName ||
          emailController.text != user.email;
    });
  }

  Future<void> _updateUser() async {
    final user =
        ref.read(userControllerProvider).selectedUser ??
        ref.read(userControllerProvider).currentUser.value;
    if (user == null) return;

    final updatedUser = user.copyWith(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
    );

    await ref
        .read(userControllerProvider.notifier)
        .updateCurrentUser(updatedUser);
    setState(() {
      hasChanges = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile updated")));
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userControllerProvider);

    return userAsync.currentUser.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text("Error: $err")),
      data: (user) {
        if (user == null) return const SizedBox();

        // Sync controllers with user data if they are empty
        if (firstNameController.text.isEmpty) {
          firstNameController.text = user.firstName ?? '';
        }
        if (lastNameController.text.isEmpty) {
          lastNameController.text = user.lastName ?? '';
        }
        if (emailController.text.isEmpty) {
          emailController.text = user.email ?? '';
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profile",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (user.isAdmin == true)
                      const Icon(
                        Icons.verified_user,
                        color: Colors.black,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "First Name"),
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Last Name"),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: hasChanges
                          ? WidgetStateProperty.all<Color>(Colors.green)
                          : null,
                    ),
                    onPressed: hasChanges ? _updateUser : null,
                    child: userAsync.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            "Save",
                            style: TextStyle(
                              color: hasChanges ? Colors.white : Colors.grey,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

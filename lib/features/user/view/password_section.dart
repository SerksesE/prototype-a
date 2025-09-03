import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/auth/providers/auth_controller.dart';

class PasswordSection extends ConsumerStatefulWidget {
  const PasswordSection({super.key});

  @override
  ConsumerState<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends ConsumerState<PasswordSection> {
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController checkPasswordController;

  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    checkPasswordController = TextEditingController();

    currentPasswordController.addListener(_updateHasChanges);
    newPasswordController.addListener(_updateHasChanges);
    checkPasswordController.addListener(_updateHasChanges);
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    checkPasswordController.dispose();
    super.dispose();
  }

  void _updateHasChanges() {
    setState(() {
      final current = currentPasswordController.text.trim();
      final newPass = newPasswordController.text.trim();
      final confirm = checkPasswordController.text.trim();

      hasChanges =
          current.isNotEmpty &&
          newPass.isNotEmpty &&
          confirm.isNotEmpty &&
          newPass == confirm;
    });
  }

  Future<void> _updatePassword() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.changePassword(
      currentPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen for success/error messages
    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          if (prev is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully!')),
            );
            currentPasswordController.clear();
            newPasswordController.clear();
            checkPasswordController.clear();
            setState(() => hasChanges = false);
          }
        },
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    final isLoading = authState.isLoading;
    final passwordsMatch =
        newPasswordController.text.trim() ==
        checkPasswordController.text.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Password", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            TextFormField(
              controller: checkPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                errorText:
                    checkPasswordController.text.isNotEmpty && !passwordsMatch
                    ? "Passwords do not match"
                    : null,
              ),
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
                onPressed: hasChanges && !isLoading ? _updatePassword : null,
                child: isLoading
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
  }
}

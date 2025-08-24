import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/user/providers/user_controller.dart';
import 'package:prototype_a/core/utils/app_tab.dart';

class ResponsiveNavBar extends ConsumerWidget {
  const ResponsiveNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedUser = ref.watch(userControllerProvider).selectedUser;

    final navigationItems = AppTab.values.map((tab) {
      final isActive = currentIndex == tab.index;
      return Expanded(
        child: TextButton(
          onPressed: () => onTap(tab.index),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tab.iconData,
                size: isActive ? 24 : 20,
                color: isActive ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: isActive ? 18 : 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nav row
            Container(
              height: 70,
              color:
                  Theme.of(context).appBarTheme.backgroundColor ?? Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: navigationItems),
            ),
            const SizedBox(height: 28),
          ],
        ),
        // Animated selected user bar
        Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: selectedUser != null ? 28 : 0,
            width: double.infinity,
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: selectedUser != null
                ? Text(
                    '${selectedUser.firstName} ${selectedUser.lastName} — ${selectedUser.email}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

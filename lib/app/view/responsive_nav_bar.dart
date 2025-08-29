import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/features/auth/providers/auth_controller.dart';
import 'package:prototype_a/features/user/providers/user_controller.dart';
import 'package:prototype_a/core/utils/app_tab.dart';

// Data class for navigation items
class NavigationData {
  final String label;
  final int index;
  final IconData iconData;
  bool isActive;
  bool isHovering;
  bool isSignOut;

  NavigationData({
    required this.label,
    required this.index,
    required this.iconData,
    this.isActive = false,
    this.isHovering = false,
    this.isSignOut = false,
  });
}

class ResponsiveNavBar extends ConsumerStatefulWidget {
  const ResponsiveNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  ConsumerState<ResponsiveNavBar> createState() => _ResponsiveNavBarState();
}

class _ResponsiveNavBarState extends ConsumerState<ResponsiveNavBar> {
  List<NavigationData> navigationData = [];

  @override
  void initState() {
    navigationData = AppTab.values.map((tab) {
      return NavigationData(
        label: tab.label,
        index: tab.index,
        isActive: widget.currentIndex == tab.index,
        isHovering: false,
        iconData: tab.iconData,
      );
    }).toList();

    navigationData.add(
      NavigationData(
        label: 'Logout',
        index: -1,
        isActive: false,
        isHovering: false,
        iconData: Icons.logout,
        isSignOut: true,
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        items: List<BottomNavigationBarItem>.from(
          navigationData.map(
            (data) => BottomNavigationBarItem(
              icon: Icon(data.iconData),
              label: data.label,
            ),
          ),
        ),
      );
    } else {
      final selectedUser = ref.watch(userControllerProvider).selectedUser;
      final authUser = ref.watch(authControllerProvider);
      final authProvider = ref.watch(authControllerProvider.notifier);

      final List<Expanded> navigationItems = navigationData.map((tab) {
        final isActive = widget.currentIndex == tab.index;
        return Expanded(
          flex: 3,
          child: TextButton(
            onHover: (value) => setState(() => tab.isHovering = value),
            onPressed: () => !tab.isSignOut
                ? widget.onTap(tab.index)
                : authProvider.signOutAndClear(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tab.iconData,
                  size: isActive || tab.isHovering ? 24 : 20,
                  color: isActive || tab.isHovering
                      ? Colors.white
                      : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: isActive || tab.isHovering ? 18 : 16,
                    fontWeight: isActive || tab.isHovering
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isActive || tab.isHovering
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();

      final loginBar = Text(
        'Login',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );

      return Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nav row
              Container(
                height: 70,
                color:
                    Theme.of(context).appBarTheme.backgroundColor ??
                    Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: authUser.value != null
                      ? navigationItems
                      : [loginBar],
                ),
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
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/utils/app_tab.dart';

// Data class for navigation items
class NavigationData {
  final IconData icon;
  final String label;
  bool isActive;
  bool isHovering;

  NavigationData({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.isHovering = false,
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
    final iconData = [
      Icons.track_changes,
      Icons.fitness_center,
      Icons.restaurant,
      Icons.bar_chart,
      Icons.school,
      Icons.person,
    ];

    navigationData = AppTab.values.map((tab) {
      return NavigationData(
        icon: iconData[tab.index],
        label: tab.label,
        isActive: widget.currentIndex == tab.index,
        isHovering: false,
      );
    }).toList();

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
              icon: Icon(data.icon),
              label: data.label,
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(navigationData.length, (index) {
            final isActive = widget.currentIndex == index;
            return TextButton(
              onHover: (value) =>
                  setState(() => navigationData[index].isHovering = value),
              onPressed: () => widget.onTap(index),
              child: Row(
                children: [
                  Text(
                    navigationData[index].label,
                    style: TextStyle(
                      fontSize: isActive ? 20 : 16,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive || navigationData[index].isHovering
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    navigationData[index].icon,
                    size: isActive ? 24 : 20,
                    color: isActive || navigationData[index].isHovering
                        ? Colors.white
                        : Colors.grey,
                  ),
                  if (isActive)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}

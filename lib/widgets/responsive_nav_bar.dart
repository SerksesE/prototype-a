import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prototype_a/utils/app_tab.dart';

class ResponsiveNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ResponsiveNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Training',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Academy'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      );
    } else {
      final labels = AppTab.values
          .map((tab) => tab.label)
          .toList(growable: false);

      return Container(
        color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(labels.length, (index) {
            final isActive = currentIndex == index;
            return TextButton(
              onPressed: () => onTap(index),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black,
                ),
              ),
            );
          }),
        ),
      );
    }
  }
}

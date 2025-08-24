import 'package:flutter/material.dart';

enum AppTab { tracker, training, nutrition, analysis, academy, user }

extension AppTabData on AppTab {
  String get label {
    switch (this) {
      case AppTab.tracker:
        return 'Tracker';
      case AppTab.training:
        return 'Training';
      case AppTab.nutrition:
        return 'Nutrition';
      case AppTab.analysis:
        return 'Analysis';
      case AppTab.academy:
        return 'Academy';
      case AppTab.user:
        return 'User';
    }
  }

  IconData get iconData {
    switch (this) {
      case AppTab.tracker:
        return Icons.track_changes;
      case AppTab.training:
        return Icons.fitness_center;
      case AppTab.nutrition:
        return Icons.restaurant;
      case AppTab.analysis:
        return Icons.bar_chart;
      case AppTab.academy:
        return Icons.school;
      case AppTab.user:
        return Icons.person;
    }
  }

  String get path {
    switch (this) {
      case AppTab.tracker:
        return '/tracker';
      case AppTab.training:
        return '/training';
      case AppTab.nutrition:
        return '/nutrition';
      case AppTab.analysis:
        return '/analysis';
      case AppTab.academy:
        return '/academy';
      case AppTab.user:
        return '/user';
    }
  }
}

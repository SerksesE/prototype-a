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

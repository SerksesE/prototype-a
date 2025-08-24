import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototype_a/core/utils/app_tab.dart';

class CurrentIndexNotifier extends Notifier<int> {
  int _previousIndex = 0;

  @override
  int build() => 0;

  void setIndex(int newIndex) {
    _previousIndex = state;
    state = newIndex;
  }

  void syncWithLocation(String location) {
    final tabs = AppTab.values.map((t) => t.path).toList();
    final index = tabs.indexWhere((path) => location.startsWith(path));
    if (index != -1) {
      state = index;
    }
  }

  int get previousIndex => _previousIndex;
}

final currentIndexProvider = NotifierProvider<CurrentIndexNotifier, int>(
  CurrentIndexNotifier.new,
);

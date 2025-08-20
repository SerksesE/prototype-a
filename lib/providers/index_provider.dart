import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentIndexNotifier extends Notifier<int> {
  int _previousIndex = 0;

  @override
  int build() => 0;

  void setIndex(int newIndex) {
    _previousIndex = state;
    state = newIndex;
  }

  int get previousIndex => _previousIndex;
}

final currentIndexProvider = NotifierProvider<CurrentIndexNotifier, int>(
  CurrentIndexNotifier.new,
);

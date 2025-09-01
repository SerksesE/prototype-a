import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prototype_a/features/user/data/user_model.dart';

part 'admin_state.freezed.dart';

@freezed
sealed class AdminState with _$AdminState {
  const factory AdminState({
    required AsyncValue<List<UserModel?>> users,
    required bool isLoading,
    required Set<String> loadingUserIds,
  }) = _AdminState;

  factory AdminState.initial() => const AdminState(
    users: AsyncValue.loading(),
    isLoading: false,
    loadingUserIds: {},
  );
}

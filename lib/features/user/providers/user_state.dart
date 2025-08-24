import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prototype_a/features/user/data/user_model.dart';

part 'user_state.freezed.dart';

@freezed
sealed class UserState with _$UserState {
  const factory UserState({
    required AsyncValue<UserModel?> currentUser,
    required UserModel? selectedUser,
  }) = _UserState;

  factory UserState.initial() =>
      const UserState(currentUser: AsyncValue.loading(), selectedUser: null);
}

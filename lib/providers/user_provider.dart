import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_a/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  UserModel? get user => state.whenOrNull(data: (user) => user);

  @override
  Future<UserModel?> build() async {
    return _fetchCurrentUser();
  }

  Future<UserModel?> _fetchCurrentUser() async {
    final authState = ref.watch(authControllerProvider);

    return await authState.when(
      data: (firebaseUser) async {
        if (firebaseUser == null) {
          state = const AsyncData(null);
          return null;
        }

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!doc.exists) {
          final newUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            firstName: '',
            lastName: '',
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set(newUser.toJson());

          return newUser;
        }

        final user = UserModel.fromJson({...doc.data()!, 'id': doc.id});
        state = AsyncData(user);
        return user;
      },
      loading: () async {
        state = const AsyncLoading();
        return null;
      },
      error: (err, stack) async {
        state = AsyncError(err, stack);
        return null;
      },
    );
  }

  Future<void> refresh() async {
    await _fetchCurrentUser();
  }

  Future<void> clear() async {
    state = const AsyncData(null);
  }

  Future<void> updateName(String first, String last) async {
    final current = state.whenOrNull(data: (user) => user);
    if (current == null) return;

    final updated = current.copyWith(firstName: first, lastName: last);
    state = AsyncData(updated);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(updated.id)
        .update(updated.toJson());
  }
}

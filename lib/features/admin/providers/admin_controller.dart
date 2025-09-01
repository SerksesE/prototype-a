import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_a/core/utils/admin_actions.dart';
import 'package:prototype_a/features/admin/providers/admin_state.dart';
import 'package:prototype_a/features/user/data/user_model.dart';
import 'package:prototype_a/features/user/providers/user_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_controller.g.dart';

@Riverpod(keepAlive: true)
class AdminController extends _$AdminController {
  List<UserModel>? _cachedUsers;

  @override
  AdminState build() {
    Future.microtask(() => _fetchUsers());
    return AdminState.initial();
  }

  Future<List<UserModel>> _fetchUsers() async {
    try {
      // Riverpod already sets loading before this runs
      if (_cachedUsers != null) return _cachedUsers!;

      final currentUser = await _getCurrentUser();
      if (currentUser == null || !(currentUser.isAdmin ?? false)) {
        return [];
      }

      final usersSnap = await FirebaseFirestore.instance
          .collection("users")
          .get();
      final adminsSnap = await FirebaseFirestore.instance
          .collection("admins")
          .get();

      final adminIds = adminsSnap.docs.map((doc) => doc.id).toSet();

      _cachedUsers = usersSnap.docs
          .map((doc) {
            return UserModel.fromJson(
              doc.data(),
            ).copyWith(isAdmin: adminIds.contains(doc.id));
          })
          .where((user) => user.id != currentUser.id)
          .toList();

      state = state.copyWith(users: AsyncValue.data(_cachedUsers!));
      return _cachedUsers!;
    } catch (e, st) {
      // This ensures your view can react to error state
      state = state.copyWith(users: AsyncValue.error(e, st));
      rethrow;
    }
  }

  Future<UserModel?> _getCurrentUser() async {
    final currentUser = ref.read(userControllerProvider).currentUser.value;
    return currentUser;
  }

  /// Call this when you want to refresh explicitly
  Future<void> refreshUsersIncremental() async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null || !(currentUser.isAdmin ?? false)) return;

      final usersSnap = await FirebaseFirestore.instance
          .collection("users")
          .get();
      final adminsSnap = await FirebaseFirestore.instance
          .collection("admins")
          .get();

      final adminIds = adminsSnap.docs.map((doc) => doc.id).toSet();

      final fetchedUsers = usersSnap.docs
          .map(
            (doc) => UserModel.fromJson(
              doc.data(),
            ).copyWith(isAdmin: adminIds.contains(doc.id)),
          )
          .where((user) => user.id != currentUser.id)
          .toList();

      // Merge new users into cachedUsers
      final currentIds = _cachedUsers?.map((u) => u.id).toSet() ?? {};
      final newUsers = fetchedUsers
          .where((u) => !currentIds.contains(u.id))
          .toList();

      if (_cachedUsers == null) {
        _cachedUsers = fetchedUsers;
      } else {
        _cachedUsers = [..._cachedUsers!, ...newUsers];
      }

      state = state.copyWith(users: AsyncValue.data(_cachedUsers!));
    } catch (e, st) {
      state = state.copyWith(users: AsyncValue.error(e, st));
      rethrow;
    }
  }

  Future<void> addAdminUser(String userId, String email) async {
    final adminActions = AdminActions();
    state = state.copyWith(loadingUserIds: {...state.loadingUserIds, userId});

    try {
      await adminActions.addAdminUser(uid: userId, email: email);
      final updatedUsers = state.users.whenData((users) {
        return users
            .map(
              (user) =>
                  user!.id == userId ? user.copyWith(isAdmin: true) : user,
            )
            .toList();
      });

      state = state.copyWith(users: updatedUsers);
    } catch (e, st) {
      state = state.copyWith(users: AsyncValue.error(e, st));
    }

    // remove from loading
    final newLoading = {...state.loadingUserIds}..remove(userId);
    state = state.copyWith(loadingUserIds: newLoading);
  }

  Future<void> removeAdminUser(String userId) async {
    final adminActions = AdminActions();
    state = state.copyWith(loadingUserIds: {...state.loadingUserIds, userId});

    try {
      await adminActions.removeAdminUser(uid: userId);
      final updatedUsers = state.users.whenData((users) {
        return users
            .map(
              (user) =>
                  user!.id == userId ? user.copyWith(isAdmin: false) : user,
            )
            .toList();
      });

      state = state.copyWith(users: updatedUsers);
    } catch (e, st) {
      state = state.copyWith(users: AsyncValue.error(e, st));
    }

    // remove from loading
    final newLoading = {...state.loadingUserIds}..remove(userId);
    state = state.copyWith(loadingUserIds: newLoading);
  }

  Future<void> deleteUser(String userId) async {
    final AdminActions adminActions = AdminActions();
    state = state.copyWith(isLoading: true);

    try {
      await adminActions.deleteUser(uid: userId);

      if (_cachedUsers != null) {
        _cachedUsers!.removeWhere((u) => u.id == userId);
        state = state.copyWith(users: AsyncValue.data(_cachedUsers!));
      }
    } catch (e, st) {
      state = state.copyWith(users: AsyncValue.error(e, st));
    }

    state = state.copyWith(isLoading: false);
  }
}

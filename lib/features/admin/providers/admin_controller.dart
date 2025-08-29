import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype_a/features/user/data/user_model.dart';
import 'package:prototype_a/features/user/providers/user_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_controller.g.dart';

@Riverpod(keepAlive: true)
class AdminController extends _$AdminController {
  List<UserModel>? _cachedUsers;

  @override
  Future<List<UserModel>> build() async {
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

      _cachedUsers = usersSnap.docs.map((doc) {
        return UserModel.fromJson(
          doc.data(),
        ).copyWith(isAdmin: adminIds.contains(doc.id));
      }).toList();

      return _cachedUsers!;
    } catch (e, st) {
      // This ensures your view can react to error state
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<UserModel?> _getCurrentUser() async {
    final currentUser = ref.read(userControllerProvider).currentUser.value;
    return currentUser;
  }

  /// Call this when you want to refresh explicitly
  Future<void> refreshUsers() async {
    _cachedUsers = null;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> updateUserRole(String userId, String role) async {
    await FirebaseFirestore.instance.collection('admins').doc(userId).set({});
    await refreshUsers(); // refresh only on explicit update
  }

  Future<void> deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    await refreshUsers(); // refresh only on explicit delete
  }
}

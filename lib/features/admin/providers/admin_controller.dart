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
    // fetch only once
    if (_cachedUsers != null) return _cachedUsers!;

    final currentUser = await _getCurrentUser();
    if (currentUser == null || !(currentUser.isAdmin ?? false)) return [];

    final query = await FirebaseFirestore.instance.collection('users').get();
    _cachedUsers = query.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();

    return _cachedUsers!;
  }

  Future<UserModel?> _getCurrentUser() async {
    final currentUser = ref.read(userControllerProvider).currentUser.value;
    return currentUser;
  }

  /// Call this when you want to refresh explicitly
  Future<void> refreshUsers() async {
    _cachedUsers = null;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }

  Future<void> updateUserRole(String userId, String role) async {
    await FirebaseFirestore.instance.collection('admins').doc(userId).set({});
    await refreshUsers(); // refresh only on explicit update
  }
}

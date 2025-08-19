import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype_a/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  User? build() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> signIn({required String email, required String password}) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading() as User?;
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // check if usermodel should be full of nullable fields (email)
      final newUser = UserModel(
        id: credential.user!.uid,
        email: credential.user!.email,
        firstName: '',
        lastName: '',
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(credential.user!.uid)
          .set(newUser.toJson());

      state = AsyncData(credential.user as AsyncValue<User?>) as User?;
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e, st) as User?;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

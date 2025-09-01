import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Lightweight Result for success/error without throwing.
class Result<T> {
  final T? data;
  final String? error;

  const Result._({this.data, this.error});
  bool get isSuccess => error == null;

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(String message) => Result._(error: message);
}

class AdminActions {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  AdminActions({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    String region = 'europe-west4',
  }) : _functions = functions ?? FirebaseFunctions.instanceFor(region: region),
       _auth = auth ?? FirebaseAuth.instance;

  Future<Result<Map<String, dynamic>>> _call(
    String name,
    Map<String, dynamic> params, {
    bool refreshIdToken = true,
  }) async {
    try {
      // 1) Must be logged in (auth context is added automatically to onCall)
      final user = _auth.currentUser;
      if (user == null) {
        return Result.failure('Not authenticated.');
      }

      // 2) Optional refresh so custom-claims (admin) are up-to-date
      if (refreshIdToken) {
        await user.getIdToken(true);
      }

      // 3) Call function
      final callable = _functions.httpsCallable(name);
      final res = await callable.call<Map<String, dynamic>>(params);

      // 4) Normalize result
      final data = res.data;

      return Result.success(data);
    } on FirebaseFunctionsException catch (e) {
      // Firebase Functions known errors
      final msg = e.message?.isNotEmpty == true ? e.message! : 'Function error';
      return Result.failure('[${e.code}] $msg');
    } catch (e) {
      return Result.failure('Unexpected error calling $name: $e');
    }
  }

  Future<Result<Map<String, dynamic>>> bootstrapFirstAdmin({
    required String uid,
    required String email,
  }) {
    return _call('bootstrapFirstAdmin', {'uid': uid, 'email': email});
  }

  Future<Result<Map<String, dynamic>>> addAdminUser({
    required String uid,
    required String email,
  }) async {
    return _call('addAdminUser', {'uid': uid, 'email': email});
  }

  Future<Result<Map<String, dynamic>>> removeAdminUser({required String uid}) {
    return _call('removeAdminUser', {'uid': uid});
  }

  Future<Result<Map<String, dynamic>>> deleteUser({required String uid}) {
    // Refresh token too (important if claims just changed)
    return _call('deleteUser', {'uid': uid}, refreshIdToken: true);
  }
}

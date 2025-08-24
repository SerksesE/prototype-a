// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(AdminController)
const adminControllerProvider = AdminControllerProvider._();

final class AdminControllerProvider
    extends $AsyncNotifierProvider<AdminController, List<UserModel>> {
  const AdminControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminControllerHash();

  @$internal
  @override
  AdminController create() => AdminController();
}

String _$adminControllerHash() => r'a4d5209a1ad8ca201f85f6f0c5c67af46e88a2ea';

abstract class _$AdminController extends $AsyncNotifier<List<UserModel>> {
  FutureOr<List<UserModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<UserModel>>, List<UserModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UserModel>>, List<UserModel>>,
              AsyncValue<List<UserModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

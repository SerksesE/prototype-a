// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(AdminController)
const adminControllerProvider = AdminControllerProvider._();

final class AdminControllerProvider
    extends $NotifierProvider<AdminController, AdminState> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminState>(value),
    );
  }
}

String _$adminControllerHash() => r'0aa4044a5b083877579a5d9479e4fe0cf54f5172';

abstract class _$AdminController extends $Notifier<AdminState> {
  AdminState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AdminState, AdminState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminState, AdminState>,
              AdminState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

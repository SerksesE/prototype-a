import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.g.dart';
part 'user_model.freezed.dart';

@freezed
sealed class UserModel with _$UserModel {
  factory UserModel({
    required String? id,
    required String? email,
    required String? firstName,
    required String? lastName,

    // Currently ignored
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool? isAdmin,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

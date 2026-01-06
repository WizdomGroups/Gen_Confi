import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String role;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? gender;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? avatarUrl,
    String? gender,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
    );
  }
}

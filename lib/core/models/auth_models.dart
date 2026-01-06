import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class SignupRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String gender;

  SignupRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  final UserModel user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

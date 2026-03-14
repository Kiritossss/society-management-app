import 'user_model.dart';

class AuthTokenModel {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  const AuthTokenModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) => AuthTokenModel(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

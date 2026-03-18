import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/auth_token_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocietyLookupItem {
  final String societyId;
  final String societyName;

  const SocietyLookupItem({required this.societyId, required this.societyName});

  factory SocietyLookupItem.fromJson(Map<String, dynamic> json) =>
      SocietyLookupItem(
        societyId: json['society_id'] as String,
        societyName: json['society_name'] as String,
      );
}

class AuthService {
  final Dio _dio = ApiClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Look up which societies an email belongs to.
  Future<List<SocietyLookupItem>> lookupSocieties({
    required String email,
  }) async {
    final response = await _dio.post(
      ApiConstants.lookup,
      data: {'email': email},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['societies'] as List;
    return list
        .map((e) => SocietyLookupItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Login with society code + email + password.
  Future<AuthTokenModel> login({
    required String societyId,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      queryParameters: {'society_id': societyId},
      data: {'email': email, 'password': password},
    );
    final token =
        AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    await _persistSession(token);
    return token;
  }

  /// Activate account using invite token + set password.
  Future<AuthTokenModel> activate({
    required String email,
    required String inviteToken,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.activate,
      data: {'email': email, 'invite_token': inviteToken, 'password': password},
    );
    final token =
        AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    await _persistSession(token);
    return token;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    return token != null;
  }

  Future<void> _persistSession(AuthTokenModel token) async {
    await Future.wait([
      _storage.write(
          key: AppConstants.keyAccessToken, value: token.accessToken),
      _storage.write(
          key: AppConstants.keySocietyId, value: token.user.societyId),
      _storage.write(key: AppConstants.keyUserId, value: token.user.id),
      _storage.write(key: AppConstants.keyUserRole, value: token.user.role),
    ]);
  }
}

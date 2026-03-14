import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/auth_token_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
    final token = AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    await _persistSession(token);
    return token;
  }

  Future<void> register({
    required String societyId,
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      ApiConstants.userRegister,
      queryParameters: {'society_id': societyId},
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': 'member',
      },
    );
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.keyAccessToken);
    return token != null;
  }

  Future<String?> getSavedSocietyId() async {
    return _storage.read(key: AppConstants.keySocietyId);
  }

  Future<void> _persistSession(AuthTokenModel token) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyAccessToken, value: token.accessToken),
      _storage.write(key: AppConstants.keySocietyId, value: token.user.societyId),
      _storage.write(key: AppConstants.keyUserId, value: token.user.id),
      _storage.write(key: AppConstants.keyUserRole, value: token.user.role),
    ]);
  }
}

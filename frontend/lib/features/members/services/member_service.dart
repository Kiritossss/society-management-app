import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/user_model.dart';

class MemberService {
  final Dio _dio = ApiClient().dio;

  Future<List<UserModel>> getMembers({int skip = 0, int limit = 50}) async {
    final response = await _dio.get(
      '/api/v1/members/',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> addMember({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? unitId,
  }) async {
    final response = await _dio.post(
      '/api/v1/members/',
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role,
        if (unitId != null) 'unit_id': unitId,
      },
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> assignUnit(String userId, String? unitId) async {
    final response = await _dio.patch(
      '/api/v1/members/$userId/unit',
      data: {'unit_id': unitId},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> deactivateMember(String userId) async {
    final response = await _dio.patch('/api/v1/members/$userId/deactivate');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}

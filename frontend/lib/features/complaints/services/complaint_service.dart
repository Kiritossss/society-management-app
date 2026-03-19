import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/complaint_model.dart';

class ComplaintService {
  final Dio _dio = ApiClient().dio;

  Future<List<ComplaintModel>> getComplaints({int skip = 0, int limit = 50}) async {
    final response = await _dio.get(
      '/api/v1/complaints/',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ComplaintModel> getComplaint(String complaintId) async {
    final response = await _dio.get('/api/v1/complaints/$complaintId');
    return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ComplaintModel> createComplaint({
    required String title,
    required String description,
    required String category,
    String? imageUrl,
  }) async {
    final response = await _dio.post(
      '/api/v1/complaints/',
      data: {
        'title': title,
        'description': description,
        'category': category,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );
    return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ComplaintModel> updateStatus(String complaintId, String status) async {
    final response = await _dio.patch(
      '/api/v1/complaints/$complaintId/status',
      data: {'status': status},
    );
    return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteComplaint(String complaintId) async {
    await _dio.delete('/api/v1/complaints/$complaintId');
  }
}

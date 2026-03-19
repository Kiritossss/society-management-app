import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/visitor_model.dart';

class VisitorService {
  final Dio _dio = ApiClient().dio;

  Future<List<VisitorModel>> getVisitors({int skip = 0, int limit = 50, String? status}) async {
    final response = await _dio.get(
      '${ApiConstants.visitors}/',
      queryParameters: {
        'skip': skip,
        'limit': limit,
        if (status != null) 'status': status,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => VisitorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<VisitorModel>> getPendingVisitors() async {
    final response = await _dio.get(ApiConstants.visitorPending);
    final list = response.data as List<dynamic>;
    return list.map((e) => VisitorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<VisitorModel>> getPreApprovedVisitors() async {
    final response = await _dio.get(ApiConstants.visitorPreApproved);
    final list = response.data as List<dynamic>;
    return list.map((e) => VisitorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VisitorModel> preApprove({
    required String visitorName,
    String? visitorPhone,
    int visitorCount = 1,
    String purpose = 'guest',
    String? vehicleNumber,
    String? expectedAt,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiConstants.visitorPreApprove,
      data: {
        'visitor_name': visitorName,
        if (visitorPhone != null) 'visitor_phone': visitorPhone,
        'visitor_count': visitorCount,
        'purpose': purpose,
        if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
        if (expectedAt != null) 'expected_at': expectedAt,
        if (notes != null) 'notes': notes,
      },
    );
    return VisitorModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VisitorModel> logEntry({
    required String visitorName,
    String? visitorPhone,
    int visitorCount = 1,
    String purpose = 'guest',
    String? vehicleNumber,
    String? unitId,
    String? residentId,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiConstants.visitorLogEntry,
      data: {
        'visitor_name': visitorName,
        if (visitorPhone != null) 'visitor_phone': visitorPhone,
        'visitor_count': visitorCount,
        'purpose': purpose,
        if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
        if (unitId != null) 'unit_id': unitId,
        if (residentId != null) 'resident_id': residentId,
        if (notes != null) 'notes': notes,
      },
    );
    return VisitorModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VisitorModel> approveVisitor(String visitorId) async {
    final response = await _dio.patch('${ApiConstants.visitors}/$visitorId/approve');
    return VisitorModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VisitorModel> denyVisitor(String visitorId) async {
    final response = await _dio.patch('${ApiConstants.visitors}/$visitorId/deny');
    return VisitorModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VisitorModel> checkIn(String visitorId) async {
    final response = await _dio.patch('${ApiConstants.visitors}/$visitorId/check-in');
    return VisitorModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VisitorModel> checkOut(String visitorId) async {
    final response = await _dio.patch('${ApiConstants.visitors}/$visitorId/check-out');
    return VisitorModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteVisitor(String visitorId) async {
    await _dio.delete('${ApiConstants.visitors}/$visitorId');
  }
}

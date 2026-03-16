import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/unit_model.dart';

class UnitService {
  final Dio _dio = ApiClient().dio;

  Future<List<UnitModel>> getUnits({int skip = 0, int limit = 50}) async {
    final response = await _dio.get(
      '/api/v1/units/',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UnitModel> createUnit({
    required String unitNumber,
    String? blockName,
    String? floorNumber,
    String? unitType,
    double? areaSqft,
  }) async {
    final response = await _dio.post(
      '/api/v1/units/',
      data: {
        'unit_number': unitNumber,
        if (blockName != null) 'block_name': blockName,
        if (floorNumber != null) 'floor_number': floorNumber,
        if (unitType != null) 'unit_type': unitType,
        if (areaSqft != null) 'area_sqft': areaSqft,
      },
    );
    return UnitModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<UnitModel>> createUnitsBulk(
      List<Map<String, dynamic>> units) async {
    final response = await _dio.post(
      '/api/v1/units/bulk',
      data: {'units': units},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUnit(String unitId) async {
    await _dio.delete('/api/v1/units/$unitId');
  }
}

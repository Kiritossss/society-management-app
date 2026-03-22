import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/notice_model.dart';

class NoticeService {
  final Dio _dio = ApiClient().dio;

  Future<List<NoticeModel>> getNotices({int skip = 0, int limit = 50}) async {
    final response = await _dio.get(
      '/api/v1/notices/',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => NoticeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NoticeModel> getNotice(String noticeId) async {
    final response = await _dio.get('/api/v1/notices/$noticeId');
    return NoticeModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NoticeModel> createNotice({
    required String title,
    required String body,
    String priority = 'normal',
    bool isPinned = false,
    String? imageUrl,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'body': body,
      'priority': priority,
      'is_pinned': isPinned,
    };
    if (imageUrl != null) data['image_url'] = imageUrl;

    final response = await _dio.post('/api/v1/notices/', data: data);
    return NoticeModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NoticeModel> updateNotice(
    String noticeId, {
    String? title,
    String? body,
    String? priority,
    bool? isPinned,
    String? imageUrl,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (body != null) data['body'] = body;
    if (priority != null) data['priority'] = priority;
    if (isPinned != null) data['is_pinned'] = isPinned;
    if (imageUrl != null) data['image_url'] = imageUrl;

    final response = await _dio.patch('/api/v1/notices/$noticeId', data: data);
    return NoticeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Upload an image and return its URL path.
  Future<String> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/api/v1/notices/upload-image',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data['image_url'] as String;
  }

  Future<void> deleteNotice(String noticeId) async {
    await _dio.delete('/api/v1/notices/$noticeId');
  }
}

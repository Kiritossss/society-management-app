class NoticePriority {
  static const String normal = 'normal';
  static const String important = 'important';
  static const String urgent = 'urgent';

  static const List<String> values = [normal, important, urgent];
}

class NoticeModel {
  final String id;
  final String societyId;
  final String postedById;
  final String title;
  final String body;
  final String priority;
  final bool isPinned;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoticeModel({
    required this.id,
    required this.societyId,
    required this.postedById,
    required this.title,
    required this.body,
    required this.priority,
    required this.isPinned,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
        id: json['id'] as String,
        societyId: json['society_id'] as String,
        postedById: json['posted_by_id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        priority: json['priority'] as String,
        isPinned: json['is_pinned'] as bool,
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

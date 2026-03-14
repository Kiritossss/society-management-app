class ComplaintCategory {
  static const String maintenance = 'maintenance';
  static const String noise = 'noise';
  static const String cleanliness = 'cleanliness';
  static const String security = 'security';
  static const String other = 'other';

  static const List<String> values = [
    maintenance,
    noise,
    cleanliness,
    security,
    other,
  ];
}

class ComplaintStatus {
  static const String open = 'open';
  static const String inProgress = 'in_progress';
  static const String resolved = 'resolved';
  static const String closed = 'closed';
}

class ComplaintModel {
  final String id;
  final String societyId;
  final String raisedById;
  final String title;
  final String description;
  final String category;
  final String status;
  final String? imageUrl;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComplaintModel({
    required this.id,
    required this.societyId,
    required this.raisedById,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.imageUrl,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) => ComplaintModel(
        id: json['id'] as String,
        societyId: json['society_id'] as String,
        raisedById: json['raised_by_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        status: json['status'] as String,
        imageUrl: json['image_url'] as String?,
        resolvedAt: json['resolved_at'] != null
            ? DateTime.parse(json['resolved_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

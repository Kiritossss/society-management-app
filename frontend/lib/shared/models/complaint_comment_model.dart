class ComplaintCommentModel {
  final String id;
  final String complaintId;
  final String userId;
  final String userName;
  final String body;
  final DateTime createdAt;

  const ComplaintCommentModel({
    required this.id,
    required this.complaintId,
    required this.userId,
    required this.userName,
    required this.body,
    required this.createdAt,
  });

  factory ComplaintCommentModel.fromJson(Map<String, dynamic> json) =>
      ComplaintCommentModel(
        id: json['id'] as String,
        complaintId: json['complaint_id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class VisitorModel {
  final String id;
  final String societyId;
  final String? unitId;
  final String? residentId;
  final String visitorName;
  final String? visitorPhone;
  final int visitorCount;
  final String purpose;
  final String? vehicleNumber;
  final String? notes;
  final String status;
  final String? preApprovedById;
  final String? checkedInById;
  final String? expectedAt;
  final String? checkedInAt;
  final String? checkedOutAt;
  final String createdAt;
  final String updatedAt;

  const VisitorModel({
    required this.id,
    required this.societyId,
    this.unitId,
    this.residentId,
    required this.visitorName,
    this.visitorPhone,
    required this.visitorCount,
    required this.purpose,
    this.vehicleNumber,
    this.notes,
    required this.status,
    this.preApprovedById,
    this.checkedInById,
    this.expectedAt,
    this.checkedInAt,
    this.checkedOutAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) => VisitorModel(
        id: json['id'] as String,
        societyId: json['society_id'] as String,
        unitId: json['unit_id'] as String?,
        residentId: json['resident_id'] as String?,
        visitorName: json['visitor_name'] as String,
        visitorPhone: json['visitor_phone'] as String?,
        visitorCount: json['visitor_count'] as int,
        purpose: json['purpose'] as String,
        vehicleNumber: json['vehicle_number'] as String?,
        notes: json['notes'] as String?,
        status: json['status'] as String,
        preApprovedById: json['pre_approved_by_id'] as String?,
        checkedInById: json['checked_in_by_id'] as String?,
        expectedAt: json['expected_at'] as String?,
        checkedInAt: json['checked_in_at'] as String?,
        checkedOutAt: json['checked_out_at'] as String?,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
      );

  String get statusLabel => status.replaceAll('_', ' ');

  bool get isPending => status == 'pending';
  bool get isPreApproved => status == 'pre_approved';
  bool get isCheckedIn => status == 'checked_in';
  bool get isCheckedOut => status == 'checked_out';
}

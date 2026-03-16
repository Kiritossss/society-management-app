class UnitModel {
  final String id;
  final String societyId;
  final String? blockName;
  final String? floorNumber;
  final String unitNumber;
  final String? unitType;
  final double? areaSqft;
  final bool isOccupied;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnitModel({
    required this.id,
    required this.societyId,
    this.blockName,
    this.floorNumber,
    required this.unitNumber,
    this.unitType,
    this.areaSqft,
    required this.isOccupied,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) => UnitModel(
        id: json['id'] as String,
        societyId: json['society_id'] as String,
        blockName: json['block_name'] as String?,
        floorNumber: json['floor_number'] as String?,
        unitNumber: json['unit_number'] as String,
        unitType: json['unit_type'] as String?,
        areaSqft: (json['area_sqft'] as num?)?.toDouble(),
        isOccupied: json['is_occupied'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  /// Human-readable label e.g. "Tower A / Floor 3 / 301" or just "House 12"
  String get displayLabel {
    final parts = <String>[];
    if (blockName != null) parts.add(blockName!);
    if (floorNumber != null) parts.add('Floor $floorNumber');
    parts.add(unitNumber);
    return parts.join(' / ');
  }
}

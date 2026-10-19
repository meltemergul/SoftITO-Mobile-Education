enum CenterType {
  kizilay('Kızılay'),
  hospital('Hastane'),
  mobile('Seyyar');

  final String label;

  const CenterType(this.label);
}

class DonationCenterModel {
  final String id;
  final String name;
  final String address;
  final CenterType type;
  final String workingHours;
  final double distanceKm;

  /// 0.0 - 1.0 arası doluluk oranı.
  final double occupancy;
  final bool isOpen;

  const DonationCenterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.workingHours,
    required this.distanceKm,
    required this.occupancy,
    required this.isOpen,
  });

  int get estimatedWaitMinutes => (occupancy * 45).round();

  DonationCenterModel copyWith({
    String? id,
    String? name,
    String? address,
    CenterType? type,
    String? workingHours,
    double? distanceKm,
    double? occupancy,
    bool? isOpen,
  }) {
    return DonationCenterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      type: type ?? this.type,
      workingHours: workingHours ?? this.workingHours,
      distanceKm: distanceKm ?? this.distanceKm,
      occupancy: occupancy ?? this.occupancy,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  factory DonationCenterModel.fromJson(Map<String, dynamic> json) {
    return DonationCenterModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      type: CenterType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CenterType.hospital,
      ),
      workingHours: json['workingHours'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      occupancy: (json['occupancy'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['isOpen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type.name,
      'workingHours': workingHours,
      'distanceKm': distanceKm,
      'occupancy': occupancy,
      'isOpen': isOpen,
    };
  }
}

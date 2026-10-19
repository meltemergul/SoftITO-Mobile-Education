enum BloodGroup {
  aPos('A+'),
  aNeg('A-'),
  bPos('B+'),
  bNeg('B-'),
  abPos('AB+'),
  abNeg('AB-'),
  zeroPos('0+'),
  zeroNeg('0-');

  final String label;

  const BloodGroup(this.label);

  static BloodGroup fromLabel(String? label) {
    return BloodGroup.values.firstWhere(
      (group) => group.label == label,
      orElse: () => BloodGroup.zeroNeg,
    );
  }
}

enum UrgencyLevel { critical, high, normal }

class UrgentRequestModel {
  final String id;
  final String hospitalName;
  final String city;
  final BloodGroup bloodGroup;
  final int unitsNeeded;
  final int respondedDonors;
  final UrgencyLevel urgency;

  const UrgentRequestModel({
    required this.id,
    required this.hospitalName,
    required this.city,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.respondedDonors,
    required this.urgency,
  });

  bool get isFulfilled => respondedDonors >= unitsNeeded;

  int get remainingUnits =>
      (unitsNeeded - respondedDonors).clamp(0, unitsNeeded);

  UrgentRequestModel copyWith({
    String? id,
    String? hospitalName,
    String? city,
    BloodGroup? bloodGroup,
    int? unitsNeeded,
    int? respondedDonors,
    UrgencyLevel? urgency,
  }) {
    return UrgentRequestModel(
      id: id ?? this.id,
      hospitalName: hospitalName ?? this.hospitalName,
      city: city ?? this.city,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      unitsNeeded: unitsNeeded ?? this.unitsNeeded,
      respondedDonors: respondedDonors ?? this.respondedDonors,
      urgency: urgency ?? this.urgency,
    );
  }

  factory UrgentRequestModel.fromJson(Map<String, dynamic> json) {
    return UrgentRequestModel(
      id: json['id'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? '',
      city: json['city'] as String? ?? '',
      bloodGroup: BloodGroup.fromLabel(json['bloodGroup'] as String?),
      unitsNeeded: (json['unitsNeeded'] as num?)?.toInt() ?? 0,
      respondedDonors: (json['respondedDonors'] as num?)?.toInt() ?? 0,
      urgency: UrgencyLevel.values.firstWhere(
        (level) => level.name == json['urgency'],
        orElse: () => UrgencyLevel.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospitalName': hospitalName,
      'city': city,
      'bloodGroup': bloodGroup.label,
      'unitsNeeded': unitsNeeded,
      'respondedDonors': respondedDonors,
      'urgency': urgency.name,
    };
  }
}

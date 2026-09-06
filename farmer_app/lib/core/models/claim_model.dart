enum ClaimStatus {
  submitted,
  verified,
  assessed,
  approved,
  rejected
}

class ClaimModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String damageReason;
  final String description;
  final List<String> photoPaths; // Exactly 5 photos
  final DateTime dateSubmitted;
  final ClaimStatus status;
  final String? officerNotes;
  final double? estimatedPayout;

  ClaimModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.damageReason,
    required this.description,
    required this.photoPaths,
    required this.dateSubmitted,
    required this.status,
    this.officerNotes,
    this.estimatedPayout,
  });

  ClaimModel copyWith({
    List<String>? photoPaths,
    ClaimStatus? status,
    String? officerNotes,
    double? estimatedPayout,
  }) {
    return ClaimModel(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      damageReason: damageReason,
      description: description,
      photoPaths: photoPaths ?? this.photoPaths,
      dateSubmitted: dateSubmitted,
      status: status ?? this.status,
      officerNotes: officerNotes ?? this.officerNotes,
      estimatedPayout: estimatedPayout ?? this.estimatedPayout,
    );
  }
}

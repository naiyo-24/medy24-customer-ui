class LabProfile {
  final String labId;
  final String labName;
  final String address;
  final double rating;
  final String nablAccreditationNumber;
  final String isoAccreditationNumber; // As fallback
  final String ownerName;

  LabProfile({
    required this.labId,
    required this.labName,
    required this.address,
    required this.rating,
    required this.nablAccreditationNumber,
    required this.isoAccreditationNumber,
    required this.ownerName,
  });

  factory LabProfile.fromJson(Map<String, dynamic> json) {
    return LabProfile(
      labId: json['lab_id'] ?? '',
      labName: json['lab_name'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      nablAccreditationNumber: json['nabl_accreditation_number'] ?? '',
      isoAccreditationNumber: json['iso_accreditation_number'] ?? '',
      ownerName: json['owner_name'] ?? '',
    );
  }
}

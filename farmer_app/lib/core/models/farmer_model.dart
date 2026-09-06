class FarmerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String aadhaar;
  final String residentialAddress;
  final String fieldAddress;
  final double latitude;
  final double longitude;
  final double landAreaAcres;
  final String selectedCrop;
  final List<List<double>> polygonBoundary; // Coordinates forming the field polygon

  FarmerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.aadhaar,
    required this.residentialAddress,
    required this.fieldAddress,
    required this.latitude,
    required this.longitude,
    required this.landAreaAcres,
    required this.selectedCrop,
    required this.polygonBoundary,
  });

  FarmerModel copyWith({
    String? name,
    String? phone,
    String? aadhaar,
    String? residentialAddress,
    String? fieldAddress,
    double? latitude,
    double? longitude,
    double? landAreaAcres,
    String? selectedCrop,
  }) {
    return FarmerModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      aadhaar: aadhaar ?? this.aadhaar,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      fieldAddress: fieldAddress ?? this.fieldAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landAreaAcres: landAreaAcres ?? this.landAreaAcres,
      selectedCrop: selectedCrop ?? this.selectedCrop,
      polygonBoundary: polygonBoundary,
    );
  }
}

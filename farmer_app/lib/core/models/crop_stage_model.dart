class CropStageModel {
  final int stageNumber; // 1 to 5
  final String stageNameEn;
  final String stageNameHi;
  final DateTime startDate;
  final DateTime endDate;
  List<String> uploadedPhotoPaths;
  DateTime? uploadedAt;
  double? latitude;
  double? longitude;

  CropStageModel({
    required this.stageNumber,
    required this.stageNameEn,
    required this.stageNameHi,
    required this.startDate,
    required this.endDate,
    List<String>? uploadedPhotoPaths,
    this.uploadedAt,
    this.latitude,
    this.longitude,
  }) : uploadedPhotoPaths = uploadedPhotoPaths ?? [];

  bool isDateWithinRange(DateTime date) {
    // Compare dates ignoring time
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return date.isAfter(s.subtract(const Duration(seconds: 1))) && date.isBefore(e);
  }

  bool get isUploaded => uploadedPhotoPaths.isNotEmpty;
  int get photoCount => uploadedPhotoPaths.length;
  bool get isMaxPhotos => uploadedPhotoPaths.length >= 5;

  void addPhoto(String path) {
    if (uploadedPhotoPaths.length < 5) {
      uploadedPhotoPaths.add(path);
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < uploadedPhotoPaths.length) {
      uploadedPhotoPaths.removeAt(index);
    }
  }
}

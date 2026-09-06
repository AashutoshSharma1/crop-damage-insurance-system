class CropHealthModel {
  final String statusIndicator;
  final String statusMessage;
  final double temperature;
  final double humidity;
  final double rainfallMm;

  CropHealthModel({
    required this.statusIndicator,
    required this.statusMessage,
    required this.temperature,
    required this.humidity,
    required this.rainfallMm,
  });

  factory CropHealthModel.fromJson(Map<String, dynamic> json) {
    return CropHealthModel(
      statusIndicator: json['status_indicator'] ?? 'UNKNOWN',
      statusMessage: json['status_message'] ?? 'No data provided.',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
enum CropHealthStatus { good, warning, bad }

class DailyForecast {
  final String dayName;
  final double tempHigh;
  final double tempLow;
  final double rainChancePct;
  final String condition;
  final String icon;

  DailyForecast({
    required this.dayName,
    required this.tempHigh,
    required this.tempLow,
    required this.rainChancePct,
    required this.condition,
    required this.icon,
  });
}

class WeatherModel {
  final double temperature;
  final double humidity;
  final double rainfallMm;
  final double windSpeedKmh;
  final String condition;
  final List<DailyForecast> forecast5Days;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.rainfallMm,
    required this.windSpeedKmh,
    required this.condition,
    required this.forecast5Days,
  });

  CropHealthStatus evaluateCropHealth() {
    // Evaluation Logic:
    // If rainfall > 90mm or humidity > 88% -> Bad condition (Flooding/Extreme moisture/pest threat)
    // If rainfall > 40mm or humidity > 80% or temp > 38°C -> Warning condition
    // Otherwise -> Good condition
    if (rainfallMm > 90 || humidity > 88) {
      return CropHealthStatus.bad;
    } else if (rainfallMm > 40 || humidity > 78 || temperature > 38) {
      return CropHealthStatus.warning;
    }
    return CropHealthStatus.good;
  }
}

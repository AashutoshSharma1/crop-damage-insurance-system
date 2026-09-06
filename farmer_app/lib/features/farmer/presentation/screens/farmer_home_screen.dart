import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/models/weather_model.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> with SingleTickerProviderStateMixin {
  final LanguageService _langService = LanguageService();
  final AppState _appState = AppState();
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.25, end: 1.0).animate(_blinkController);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_langService, _appState]),
      builder: (context, _) {
        final t = _langService.translate;
        final farmer = _appState.activeFarmer;
        final weather = _appState.currentWeather;
        final healthStatus = weather.evaluateCropHealth();

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================================
                // 1. TOP DIV: FIELD BOUNDARY MAP (polygon outlining field)
                // =========================================================
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: Colors.green.shade800,
                        child: Row(
                          children: [
                            const Icon(Icons.map_rounded, color: Colors.amberAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t('field_map'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${farmer.landAreaAcres} ${t('land_area').split('(').first}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Interactive OpenStreetMap Field Boundary View
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(farmer.latitude, farmer.longitude),
                                initialZoom: 16.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.agri.farmer_app',
                                ),
                                PolygonLayer(
                                  polygons: [
                                    Polygon(
                                      points: farmer.polygonBoundary
                                          .map((pt) => LatLng(pt[0], pt[1]))
                                          .toList(),
                                      color: Colors.amber.withValues(alpha: 0.35),
                                      borderColor: Colors.amber,
                                      borderStrokeWidth: 3.0,
                                      isFilled: true,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(farmer.latitude, farmer.longitude),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.redAccent,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Map Overlay Info Badge
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.shade400, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.map, color: Colors.amberAccent, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            farmer.fieldAddress,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "OpenStreetMap GPS: ${farmer.latitude.toStringAsFixed(4)}° N, ${farmer.longitude.toStringAsFixed(4)}° E",
                                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade700,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "OSM Polygon Active",
                                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================================
                // 2. MIDDLE DIV: LIVE WEATHER & 5-DAY FORECAST
                // =========================================================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t('weather_title'),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                weather.condition,
                                style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Current Weather Metric Tiles
                        Row(
                          children: [
                            _buildWeatherMetricTile(
                              t('current_temp'),
                              "${weather.temperature} °C",
                              Icons.thermostat,
                              Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _buildWeatherMetricTile(
                              t('humidity'),
                              "${weather.humidity} %",
                              Icons.water_drop,
                              Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            _buildWeatherMetricTile(
                              t('rainfall'),
                              "${weather.rainfallMm} mm",
                              Icons.grain,
                              Colors.indigo,
                            ),
                            const SizedBox(width: 8),
                            _buildWeatherMetricTile(
                              t('wind'),
                              "${weather.windSpeedKmh} km/h",
                              Icons.air,
                              Colors.teal,
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          t('forecast'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),

                        // 5-Day Forecast Cards Horizontal Scroll
                        SizedBox(
                          height: 105,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: weather.forecast5Days.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final f = weather.forecast5Days[idx];
                              return Container(
                                width: 95,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      f.dayName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(f.icon, style: const TextStyle(fontSize: 22)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${f.tempHigh}° / ${f.tempLow}°",
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "🌧️ ${f.rainChancePct.toInt()}%",
                                      style: TextStyle(fontSize: 9, color: Colors.blue.shade800),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================================
                // 3. BOTTOM DIV: BLINKING LIGHT & CROP CONDITION EVALUATION
                // =========================================================
                _buildCropConditionBlinkingBox(healthStatus, t),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherMetricTile(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center, maxLines: 1),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCropConditionBlinkingBox(CropHealthStatus status, String Function(String) t) {
    Color statusColor;
    String statusTitle;
    String statusMessage;

    switch (status) {
      case CropHealthStatus.good:
        statusColor = Colors.green.shade600;
        statusTitle = t('status_good');
        statusMessage = t('msg_good');
        break;
      case CropHealthStatus.warning:
        statusColor = Colors.orange.shade700;
        statusTitle = t('status_warning');
        statusMessage = t('msg_warning');
        break;
      case CropHealthStatus.bad:
        statusColor = Colors.red.shade700;
        statusTitle = t('status_bad');
        statusMessage = t('msg_bad');
        break;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor, width: 1.5),
      ),
      color: statusColor.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Blinking Light Indicator
                AnimatedBuilder(
                  animation: _blinkAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withValues(alpha: _blinkAnimation.value),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: _blinkAnimation.value * 0.8),
                            blurRadius: 10,
                            spreadRadius: 3,
                          )
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('crop_condition_title'),
                        style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

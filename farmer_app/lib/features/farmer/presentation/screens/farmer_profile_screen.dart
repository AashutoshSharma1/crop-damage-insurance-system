import 'package:flutter/material.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/app_state.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageService langService = LanguageService();
    final AppState appState = AppState();

    return ListenableBuilder(
      listenable: Listenable.merge([langService, appState]),
      builder: (context, _) {
        final t = langService.translate;
        final farmer = appState.activeFarmer;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================================
                // 1. FINAL VERIFIED FARMER HEADER CARD (READ-ONLY)
                // =========================================================
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade900, Colors.green.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 44, color: Colors.green.shade900),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          farmer.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.verified_rounded, color: Colors.amberAccent, size: 24),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amberAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "ID: ${farmer.id}",
                                      style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    farmer.email,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),

                        // Official Registration Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeaderBadge(Icons.shield_outlined, "PMFBY Verified"),
                            _buildHeaderBadge(Icons.fingerprint_rounded, "Aadhaar Linked"),
                            _buildHeaderBadge(Icons.g_mobiledata_rounded, "Geo-Tagged"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================================
                // 2. OFFICIAL REGISTRATION DETAILS (NON-EDITABLE FINAL VIEW)
                // =========================================================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t('profile_title'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lock, size: 12, color: Colors.green.shade900),
                                  const SizedBox(width: 4),
                                  Text(
                                    "FINAL REGISTRATION",
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildReadOnlyTile(
                          icon: Icons.person,
                          label: t('farmer_name'),
                          value: farmer.name,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.badge,
                          label: t('aadhaar_no'),
                          value: farmer.aadhaar,
                          isMasked: true,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.phone,
                          label: t('phone_no'),
                          value: farmer.phone,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.home,
                          label: t('res_address'),
                          value: farmer.residentialAddress,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.landscape,
                          label: t('field_address'),
                          value: farmer.fieldAddress,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReadOnlyTile(
                                icon: Icons.my_location,
                                label: "Latitude",
                                value: farmer.latitude.toStringAsFixed(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildReadOnlyTile(
                                icon: Icons.my_location,
                                label: "Longitude",
                                value: farmer.longitude.toStringAsFixed(4),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReadOnlyTile(
                                icon: Icons.square_foot,
                                label: t('land_area'),
                                value: "${farmer.landAreaAcres} Acres",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildReadOnlyTile(
                                icon: Icons.grass,
                                label: "Registered Crop",
                                value: farmer.selectedCrop,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.amberAccent, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildReadOnlyTile({
    required IconData icon,
    required String label,
    required String value,
    bool isMasked = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green.shade800, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
        ],
      ),
    );
  }
}

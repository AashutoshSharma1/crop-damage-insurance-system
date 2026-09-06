import 'package:flutter/material.dart';
import '../../../core/services/app_state.dart';
import '../../../core/services/language_service.dart';
import '../../../core/services/api_service.dart';

class OfficerProfileScreen extends StatefulWidget {
  const OfficerProfileScreen({super.key});

  @override
  State<OfficerProfileScreen> createState() => _OfficerProfileScreenState();
}

class _OfficerProfileScreenState extends State<OfficerProfileScreen> {
  final AppState _appState = AppState();
  final LanguageService _langService = LanguageService();
  final ApiService _apiService = ApiService();
  bool _isRefreshing = false;

  Future<void> _refreshBackendData() async {
    setState(() => _isRefreshing = true);
    final data = await _apiService.fetchOfficerDashboard(_appState.officerId);
    if (data != null && data['status'] == 'success') {
      if (data.containsKey('officer')) {
        final off = data['officer'];
        if (off['name'] != null) _appState.officerName = off['name'];
        if (off['zone'] != null) _appState.officerZone = off['zone'];
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Database synced with backend API!"),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Using cached profile (Backend offline)"),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_appState, _langService]),
      builder: (context, _) {
        final t = _langService.translate;
        final claims = _appState.claimsList;
        final farmers = _appState.registeredFarmers;
        final pendingCount = claims.where((c) => c.status.name == 'submitted').length;
        final verifiedCount = claims.where((c) => c.status.name != 'submitted').length;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.teal.shade900,
            foregroundColor: Colors.white,
            elevation: 2,
            title: Text(
              t('officer_profile_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: _isRefreshing ? null : _refreshBackendData,
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: "Sync Backend Data",
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. OFFICER HEADER CARD
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.amberAccent,
                          child: Icon(Icons.admin_panel_settings, size: 42, color: Colors.teal),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _appState.officerName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t('officer_role'),
                                style: const TextStyle(fontSize: 12, color: Colors.amberAccent, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "ID: ${_appState.officerId}",
                                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. ASSIGNED AREA & CONTACT INFO CARD
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Officer Credentials & Assigned Territory",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          iconColor: Colors.teal.shade700,
                          label: t('zone_of_work'),
                          value: _appState.officerZone,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.email,
                          iconColor: Colors.blue.shade700,
                          label: "Official Email",
                          value: "officer.karnal@agri.in",
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.phone,
                          iconColor: Colors.green.shade700,
                          label: "Contact Phone",
                          value: "+91 98112 34567",
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.badge,
                          iconColor: Colors.purple.shade700,
                          label: "Department Authorization",
                          value: "Ministry of Agriculture - Karnal Division",
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. STATISTICAL OVERVIEW CARD
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Territory Inspection Performance",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatItem("Allotted Farms", "${farmers.length}", Colors.teal),
                            _buildStatItem("Total Claims", "${claims.length}", Colors.blue),
                            _buildStatItem("Pending 72h", "$pendingCount", Colors.orange),
                            _buildStatItem("Verified", "$verifiedCount", Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. ACTIONS / LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _appState.signOut();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(t('sign_out'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

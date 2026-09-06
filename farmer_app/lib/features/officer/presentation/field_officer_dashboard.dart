import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/language_service.dart';
import '../../../core/services/app_state.dart';
import '../../../core/models/claim_model.dart';
import '../../../core/models/farmer_model.dart';
import 'officer_profile_screen.dart';
import '../../farmer/presentation/widgets/quality_camera_screen.dart';

class FieldOfficerDashboard extends StatefulWidget {
  const FieldOfficerDashboard({super.key});

  @override
  State<FieldOfficerDashboard> createState() => _FieldOfficerDashboardState();
}

class _FieldOfficerDashboardState extends State<FieldOfficerDashboard> {
  final LanguageService _langService = LanguageService();
  final AppState _appState = AppState();

  // Filter Index: 0 = Total/All, 1 = Pending, 2 = Verified
  int _activeFilterIndex = 0;

  // Calculate remaining time for 72-hour deadline window
  Duration _getRemainingDeadline(DateTime submittedAt) {
    final deadline = submittedAt.add(const Duration(hours: 72));
    final remaining = deadline.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String _formatDeadline(Duration remaining) {
    if (remaining == Duration.zero) return "72h Expired!";
    final hours = remaining.inHours;
    final mins = remaining.inMinutes.remainder(60);
    return "${hours}h ${mins}m Left";
  }

  Color _getDeadlineColor(Duration remaining) {
    if (remaining == Duration.zero) return Colors.red.shade900;
    if (remaining.inHours < 24) return Colors.red.shade700;
    if (remaining.inHours < 48) return Colors.amber.shade800;
    return Colors.green.shade800;
  }

  // Launch Reusable Quality Camera Module for Task Card Photo Capture
  Future<void> _capturePhotoForClaim(BuildContext context, ClaimModel claim, FarmerModel farmer) async {
    final QualityCameraResult? result = await Navigator.push<QualityCameraResult>(
      context,
      MaterialPageRoute(
        builder: (_) => QualityCameraScreen(
          title: "Task Inspection Photo (${claim.id})",
          initialLat: farmer.latitude,
          initialLng: farmer.longitude,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result != null) {
      _appState.addClaimPhoto(claim.id, result.imagePath);
      final captureType = result.isAutoCaptured ? "Auto-Captured" : "Captured";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Field Photo $captureType & Bound to ${claim.id}! Blur Score: ${result.blurScore.toInt()}%"),
          backgroundColor: Colors.teal.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Open Interactive OpenStreetMap Modal for Field Polygons
  void _showOsmMapModal(BuildContext context, {FarmerModel? selectedFarmer}) {
    final t = _langService.translate;
    final farmers = _appState.registeredFarmers;

    final initialCenter = selectedFarmer != null
        ? LatLng(selectedFarmer.latitude, selectedFarmer.longitude)
        : const LatLng(29.6857, 76.9905);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 750,
            height: 550,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Modal Top Bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.map, color: Colors.teal.shade800),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFarmer != null
                                ? "${t('lookup_location')}: ${selectedFarmer.name}"
                                : t('map_card_title'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            selectedFarmer != null
                                ? "Khasra No. 114/2 | ${selectedFarmer.fieldAddress}"
                                : "Zone: ${_appState.officerZone} (${farmers.length} Allotted Farms)",
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // OpenStreetMap Container
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: initialCenter,
                            initialZoom: selectedFarmer != null ? 15.0 : 12.2,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.agri.crop_app',
                            ),
                            PolygonLayer(
                              polygons: farmers.map((f) {
                                final pts = f.polygonBoundary.map((c) => LatLng(c[0], c[1])).toList();
                                final isSelected = selectedFarmer != null && selectedFarmer.id == f.id;
                                return Polygon(
                                  points: pts,
                                  color: isSelected
                                      ? Colors.amber.withValues(alpha: 0.45)
                                      : Colors.teal.withValues(alpha: 0.35),
                                  borderColor: isSelected ? Colors.amber.shade900 : Colors.teal.shade800,
                                  borderStrokeWidth: isSelected ? 3.5 : 2.0,
                                  isFilled: true,
                                );
                              }).toList(),
                            ),
                            MarkerLayer(
                              markers: farmers.map((f) {
                                final isSelected = selectedFarmer != null && selectedFarmer.id == f.id;
                                return Marker(
                                  point: LatLng(f.latitude, f.longitude),
                                  width: 100,
                                  height: 55,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: isSelected ? Colors.redAccent : Colors.teal.shade900,
                                        size: isSelected ? 32 : 26,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                                        ),
                                        child: Text(
                                          "${f.name} (${f.selectedCrop})",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.red.shade900 : Colors.teal.shade900,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                        // Map Legend Overlay
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.layers, size: 14, color: Colors.teal),
                                SizedBox(width: 6),
                                Text(
                                  "OSM Live Satellite & Boundary Telemetry",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
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

  // Inspection & Verification Dialog
  void _inspectClaimModal(BuildContext context, ClaimModel claim) {
    final t = _langService.translate;
    final payoutCtrl = TextEditingController(text: claim.estimatedPayout != null && claim.estimatedPayout! > 0 ? claim.estimatedPayout!.toStringAsFixed(0) : "35000");
    final notesCtrl = TextEditingController(text: claim.officerNotes ?? "Field satellite and ground photo verification completed.");

    final farmer = _appState.registeredFarmers.firstWhere(
      (f) => f.id == claim.farmerId,
      orElse: () => _appState.activeFarmer,
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.security, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${t('claim_inspection_title')} - ${claim.id}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Farmer & Claim Summary Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Farmer Name: ${claim.farmerName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Damage Reason: ${claim.damageReason}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Explanation: ${claim.description}", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Proof Photos Gallery Preview with Camera Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Proof Photos (${claim.photoPaths.length})",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          _capturePhotoForClaim(context, claim, farmer);
                        },
                        icon: const Icon(Icons.camera_alt, size: 14),
                        label: const Text("Add Field Photo", style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal.shade900,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 85,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: claim.photoPaths.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final path = claim.photoPaths[idx];
                        final isFile = path.startsWith('/') || path.contains(':\\') || path.contains('cache');
                        return Container(
                          width: 85,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.teal.shade400, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: isFile && File(path).existsSync()
                                ? Image.file(File(path), fit: BoxFit.cover)
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.landscape, size: 24, color: Colors.teal),
                                        const SizedBox(height: 2),
                                        Text("Proof #${idx + 1}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Officer Inputs
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: "Inspector Field Verification Notes",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: payoutCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Calculated Payout Settlement (₹)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _appState.updateClaimStatus(claim.id, ClaimStatus.rejected, notes: notesCtrl.text.trim());
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Claim rejected.")));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(t('reject_claim')),
            ),
            ElevatedButton(
              onPressed: () {
                double val = double.tryParse(payoutCtrl.text) ?? 30000.0;
                _appState.updateClaimStatus(claim.id, ClaimStatus.approved, notes: notesCtrl.text.trim(), payout: val);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Claim verified & approved! ₹$val payout assigned."), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
              child: Text(t('approve_claim')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_langService, _appState]),
      builder: (context, _) {
        final t = _langService.translate;
        final claims = _appState.claimsList;
        final farmers = _appState.registeredFarmers;

        // Metric Counters
        final totalTasks = claims.length;
        final pendingTasks = claims.where((c) => c.status == ClaimStatus.submitted).length;
        final verifiedTasks = claims.where((c) => c.status != ClaimStatus.submitted).length;

        // Filtered Claims List
        List<ClaimModel> filteredClaims = claims;
        if (_activeFilterIndex == 1) {
          filteredClaims = claims.where((c) => c.status == ClaimStatus.submitted).toList();
        } else if (_activeFilterIndex == 2) {
          filteredClaims = claims.where((c) => c.status != ClaimStatus.submitted).toList();
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.teal.shade900,
            foregroundColor: Colors.white,
            elevation: 2,
            title: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OfficerProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.amberAccent,
                      child: Icon(Icons.admin_panel_settings, color: Colors.teal, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "${t('hi')}, ${_appState.officerName}",
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.amberAccent, size: 18),
                            ],
                          ),
                          Text(
                            "ID: ${_appState.officerId} | ${_appState.officerZone}",
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _langService.toggleLanguage(),
                icon: const Icon(Icons.translate, color: Colors.amberAccent, size: 18),
                label: Text(t('switch_lang'), style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              IconButton(
                onPressed: () => _appState.signOut(),
                icon: const Icon(Icons.logout),
                tooltip: t('sign_out'),
              ),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. RESIZED & BALANCED ALLOTTED FIELDS MAP CARD
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.map_rounded, size: 26, color: Colors.amberAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('map_card_title'),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Zone: ${_appState.officerZone} (${farmers.length} Allotted Farms)",
                                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.85)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showOsmMapModal(context),
                          icon: const Icon(Icons.explore, size: 16),
                          label: const Text("Open Map", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 2. THREE STAT DIV BUTTONS (RESPONSIVE FLEX CARDS)
                Row(
                  children: [
                    _buildStatFilterCard(
                      title: t('stat_total_tasks'),
                      count: "$totalTasks",
                      icon: Icons.assignment_rounded,
                      accentColor: Colors.blue.shade700,
                      index: 0,
                    ),
                    const SizedBox(width: 8),
                    _buildStatFilterCard(
                      title: t('stat_pending_tasks'),
                      count: "$pendingTasks",
                      icon: Icons.pending_actions_rounded,
                      accentColor: Colors.orange.shade800,
                      index: 1,
                    ),
                    const SizedBox(width: 8),
                    _buildStatFilterCard(
                      title: t('stat_verified_tasks'),
                      count: "$verifiedTasks",
                      icon: Icons.verified_outlined,
                      accentColor: Colors.green.shade800,
                      index: 2,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 3. TASK CARDS LIST HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Field Insurance Claim Tasks",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "Showing ${filteredClaims.length} of $totalTasks Tasks",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 4. TASK CARDS WITH CAMERA & OVERFLOW-SAFE LAYOUT
                filteredClaims.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text("No tasks found for selected filter", style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredClaims.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final claim = filteredClaims[idx];
                          final farmer = farmers.firstWhere(
                            (f) => f.id == claim.farmerId,
                            orElse: () => _appState.activeFarmer,
                          );

                          final remaining = _getRemainingDeadline(claim.dateSubmitted);
                          final deadlineText = _formatDeadline(remaining);
                          final deadlineColor = _getDeadlineColor(remaining);
                          final isVerified = claim.status != ClaimStatus.submitted;

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Farmer Avatar & Name + 72H Deadline Badge (Overflow-Safe Flex)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.teal.shade800,
                                        child: Text(
                                          claim.farmerName.isNotEmpty ? claim.farmerName[0] : "F",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              claim.farmerName,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "ID: ${claim.farmerId} | Field: ${farmer.fieldAddress}",
                                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),

                                      // 72-Hour Deadline Badge
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: deadlineColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: deadlineColor.withValues(alpha: 0.5)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.timer, size: 12, color: deadlineColor),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  deadlineText,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: deadlineColor,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),

                                  // Damage Reason Tag & Claim ID Row
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.red.shade200),
                                          ),
                                          child: Text(
                                            claim.damageReason,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "ID: ${claim.id}",
                                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    claim.description,
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),

                                  const SizedBox(height: 12),

                                  // Proof Photos Gallery Row + Interactive "Capture Field Photo" Card Button
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Attached Field Photos",
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.7)),
                                          ),
                                          Text(
                                            "${claim.photoPaths.length} Photos",
                                            style: const TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        height: 60,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: claim.photoPaths.length + 1, // +1 for Camera Action Card
                                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                                          itemBuilder: (context, photoIdx) {
                                            // Camera Capture Tile
                                            if (photoIdx == claim.photoPaths.length) {
                                              return InkWell(
                                                onTap: () => _capturePhotoForClaim(context, claim, farmer),
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber.shade50,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.amber.shade700, width: 1.5),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.camera_alt_rounded, size: 22, color: Colors.amber.shade900),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        "+ Add Photo",
                                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }

                                            final path = claim.photoPaths[photoIdx];
                                            final isFile = path.startsWith('/') || path.contains(':\\') || path.contains('cache');

                                            return Container(
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.teal.shade200),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
                                                child: isFile && File(path).existsSync()
                                                    ? Image.file(File(path), fit: BoxFit.cover)
                                                    : const Center(
                                                        child: Icon(Icons.image, size: 22, color: Colors.teal),
                                                      ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Bottom Actions Row (Wrap for zero overflow on mobile screens)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      // Look Up Field Location Button
                                      OutlinedButton.icon(
                                        onPressed: () => _showOsmMapModal(context, selectedFarmer: farmer),
                                        icon: const Icon(Icons.my_location, size: 14),
                                        label: Text(
                                          t('lookup_location'),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.teal.shade900,
                                          side: BorderSide(color: Colors.teal.shade800),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),

                                      // Inspect / Status Button
                                      ElevatedButton.icon(
                                        onPressed: () => _inspectClaimModal(context, claim),
                                        icon: Icon(isVerified ? Icons.check_circle : Icons.search, size: 14),
                                        label: Text(
                                          isVerified ? "Verified (${claim.status.name})" : t('inspect_claim'),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isVerified ? Colors.green.shade800 : Colors.teal.shade800,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper Widget for 3 Stat Filter Buttons in One Line
  Widget _buildStatFilterCard({
    required String title,
    required String count,
    required IconData icon,
    required Color accentColor,
    required int index,
  }) {
    final isSelected = _activeFilterIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? accentColor : Colors.grey.shade300,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: accentColor.withValues(alpha: 0.15),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor),
                    ),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

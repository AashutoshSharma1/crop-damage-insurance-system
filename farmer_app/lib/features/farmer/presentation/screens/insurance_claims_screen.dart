import 'package:flutter/material.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/models/claim_model.dart';

class InsuranceClaimsScreen extends StatefulWidget {
  const InsuranceClaimsScreen({super.key});

  @override
  State<InsuranceClaimsScreen> createState() => _InsuranceClaimsScreenState();
}

class _InsuranceClaimsScreenState extends State<InsuranceClaimsScreen> {
  final LanguageService _langService = LanguageService();
  final AppState _appState = AppState();
  bool _showActiveOnly = true;

  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_langService, _appState]),
      builder: (context, _) {
        final t = _langService.translate;
        final allClaims = _appState.claimsList;
        final farmerId = _appState.activeFarmer.id;

        final farmerClaims = allClaims.where((c) => c.farmerId == farmerId).toList();
        final activeClaims = farmerClaims.where((c) => c.status != ClaimStatus.approved && c.status != ClaimStatus.rejected).toList();
        final historicClaims = farmerClaims.where((c) => c.status == ClaimStatus.approved || c.status == ClaimStatus.rejected).toList();

        final displayClaims = _showActiveOnly ? activeClaims : historicClaims;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.verified_user_rounded, color: Colors.amberAccent, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('insurance_title'),
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Track live claim status timeline & settlement progress",
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Tabs (Active vs History)
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text("${t('active_claims')} (${activeClaims.length})")),
                        selected: _showActiveOnly,
                        onSelected: (val) => setState(() => _showActiveOnly = true),
                        selectedColor: Colors.blue.shade800,
                        labelStyle: TextStyle(color: _showActiveOnly ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text("${t('historic_claims')} (${historicClaims.length})")),
                        selected: !_showActiveOnly,
                        onSelected: (val) => setState(() => _showActiveOnly = false),
                        selectedColor: Colors.teal.shade800,
                        labelStyle: TextStyle(color: !_showActiveOnly ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (displayClaims.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          _showActiveOnly ? "No active insurance claims right now." : "No historic claims found.",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayClaims.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, idx) {
                      final claim = displayClaims[idx];
                      return _buildClaimTimelineCard(claim, t);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClaimTimelineCard(ClaimModel claim, String Function(String) t) {
    int currentStep = 1;
    if (claim.status == ClaimStatus.verified) currentStep = 2;
    if (claim.status == ClaimStatus.assessed) currentStep = 3;
    if (claim.status == ClaimStatus.approved) currentStep = 4;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row ID & Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${t('claim_id')}: ${claim.id}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue.shade900),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(claim.dateSubmitted),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Damage Reason
            Text(
              claim.damageReason,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 4),
            Text(
              claim.description,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Step-by-Step Timeline Bar
            const Text(
              "Claim Processing Timeline Progress:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _buildTimelineStep(1, t('status_submitted'), currentStep >= 1),
                _buildTimelineLine(currentStep >= 2),
                _buildTimelineStep(2, t('status_verified'), currentStep >= 2),
                _buildTimelineLine(currentStep >= 3),
                _buildTimelineStep(3, t('status_assessed'), currentStep >= 3),
                _buildTimelineLine(currentStep >= 4),
                _buildTimelineStep(4, t('status_approved'), currentStep >= 4),
              ],
            ),

            const SizedBox(height: 16),

            // Officer Notes Box if verified
            if (claim.officerNotes != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security_sharp, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Field Officer Note: ${claim.officerNotes}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            if (claim.estimatedPayout != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Approved Payout Amount: ₹${claim.estimatedPayout?.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ),

            const SizedBox(height: 12),

            // 5 Photos Attached Thumbnail Gallery
            Text(
              "Submitted Proof Photos (${claim.photoPaths.length}):",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 55,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: claim.photoPaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, idx) {
                  return Container(
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 20, color: Colors.green),
                          Text("#${idx + 1}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(int stepNum, String title, bool isDone) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isDone ? Colors.green : Colors.grey.shade300,
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text("$stepNum", style: const TextStyle(fontSize: 10, color: Colors.black87)),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 9, fontWeight: isDone ? FontWeight.bold : FontWeight.normal, color: isDone ? Colors.black87 : Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineLine(bool isDone) {
    return Container(
      width: 20,
      height: 2,
      color: isDone ? Colors.green : Colors.grey.shade300,
    );
  }
}

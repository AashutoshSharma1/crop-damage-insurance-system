import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/quality_camera_screen.dart';

class FileClaimScreen extends StatefulWidget {
  const FileClaimScreen({super.key});

  @override
  State<FileClaimScreen> createState() => _FileClaimScreenState();
}

class _FileClaimScreenState extends State<FileClaimScreen> {
  final LanguageService _langService = LanguageService();
  final AppState _appState = AppState();

  String? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  final List<String?> _uploadedPhotos = List.filled(5, null);
  bool _isSubmitting = false;

  Future<void> _pickPhotoForSlot(int index) async {
    final QualityCameraResult? result = await Navigator.push<QualityCameraResult>(
      context,
      MaterialPageRoute(
        builder: (_) => QualityCameraScreen(
          title: "Claim Damage Proof #${index + 1}",
          initialLat: _appState.activeFarmer.latitude,
          initialLng: _appState.activeFarmer.longitude,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _uploadedPhotos[index] = result.imagePath;
      });

      if (mounted) {
        final captureType = result.isAutoCaptured ? "Auto-captured" : "Captured";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Photo #${index + 1} $captureType! Sharpness: ${result.blurScore.toInt()}%"),
            backgroundColor: Colors.green.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _submitClaim() {
    final t = _langService.translate;
    if (_selectedReason == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select damage reason and write a description!"), backgroundColor: Colors.red),
      );
      return;
    }

    final filledPhotosCount = _uploadedPhotos.where((p) => p != null).length;
    if (filledPhotosCount < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('photos_required_err')),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final photosList = _uploadedPhotos.whereType<String>().toList();

    // Save claim into local app state
    _appState.submitInsuranceClaim(
      reason: _selectedReason!,
      description: _descriptionController.text.trim(),
      photos: photosList,
    );

    // Sync to backend Supabase database asynchronously
    ApiService().submitClaim(
      farmerId: _appState.activeFarmer.id,
      farmerName: _appState.activeFarmer.name,
      damageReason: _selectedReason!,
      description: _descriptionController.text.trim(),
      photoUrls: photosList,
    );


    setState(() {
      _isSubmitting = false;
      _descriptionController.clear();
      for (int i = 0; i < 5; i++) {
        _uploadedPhotos[i] = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('claim_success')),
        backgroundColor: Colors.green.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_langService, _appState]),
      builder: (context, _) {
        final t = _langService.translate;

        final reasons = [
          t('reason_flood'),
          t('reason_insects'),
          t('reason_drought'),
          t('reason_hailstorm'),
          t('reason_heavy_rain'),
          t('reason_disease'),
        ];

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Claim Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade800,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('file_claim_title'),
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Submit crop damage inspection request to insurance officer",
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Form Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reason Dropdown
                        Text(
                          t('damage_reason'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: const Text("Choose Damage Reason"),
                              value: _selectedReason,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.red),
                              onChanged: (val) => setState(() => _selectedReason = val),
                              items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Explanation Paragraph Text Field
                        const Text(
                          "Detailed Damage Explanation (वर्णन):",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: t('description_hint'),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        // 5 Photos Mandatory Upload Grid
                        Row(
                          children: [
                            Text(
                              t('upload_5_photos'),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${_uploadedPhotos.where((p) => p != null).length} / 5",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Grid of 5 Photo Slots
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final photoPath = _uploadedPhotos[index];
                            return GestureDetector(
                              onTap: () => _pickPhotoForSlot(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: photoPath != null ? Colors.green : Colors.red.shade300,
                                    width: photoPath != null ? 2 : 1,
                                  ),
                                ),
                                child: photoPath != null
                                    ? Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: kIsWeb
                                                ? Image.network(photoPath, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                                : Image.file(File(photoPath), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.black54,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.close, size: 14, color: Colors.white),
                                                onPressed: () => setState(() => _uploadedPhotos[index] = null),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            left: 4,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              color: Colors.black87,
                                              child: Text(
                                                "#${index + 1}",
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, color: Colors.red.shade700, size: 26),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${t('photo_slot')} ${index + 1}",
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submitClaim,
                            icon: const Icon(Icons.send_rounded),
                            label: _isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    t('submit_claim_btn'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
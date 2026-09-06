import 'package:flutter/material.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/models/crop_stage_model.dart';
import '../widgets/quality_camera_screen.dart';

class CropStagesScreen extends StatefulWidget {
  const CropStagesScreen({super.key});

  @override
  State<CropStagesScreen> createState() => _CropStagesScreenState();
}

class _CropStagesScreenState extends State<CropStagesScreen> {
  final LanguageService _langService = LanguageService();
  final AppState _appState = AppState();

  Future<void> _handleUploadStagePhoto(CropStageModel stage, String selectedCrop) async {
    if (stage.isMaxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Maximum limit of 5 photos per stage reached!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final QualityCameraResult? result = await Navigator.push<QualityCameraResult>(
      context,
      MaterialPageRoute(
        builder: (_) => QualityCameraScreen(
          title: "Stage ${stage.stageNumber} Photo ${stage.photoCount + 1}/5 Inspection",
          initialLat: _appState.activeFarmer.latitude,
          initialLng: _appState.activeFarmer.longitude,
        ),
      ),
    );

    if (result != null) {
      _appState.addCropStagePhoto(
        selectedCrop,
        stage.stageNumber,
        result.imagePath,
        result.latitude,
        result.longitude,
      );

      if (mounted) {
        final captureType = result.isAutoCaptured ? "Auto-captured" : "Captured";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Photo ${stage.photoCount}/5 $captureType! Sharpness: ${result.blurScore.toInt()}% | GPS: (${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)})",
            ),
            backgroundColor: Colors.green.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleSubmitStagePhotos(CropStageModel stage, String selectedCrop) {
    if (!stage.isUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please capture at least 1 photo before submitting stage photos."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "🎉 Stage ${stage.stageNumber} (${stage.photoCount}/5 photos) submitted and verified successfully!",
        ),
        backgroundColor: Colors.green.shade900,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_langService, _appState]),
      builder: (context, _) {
        final t = _langService.translate;
        final selectedCrop = _appState.activeFarmer.selectedCrop;
        final stages = _appState.cropStagesMap[selectedCrop] ?? [];
        final systemDate = _appState.simulatedSystemDate;
        final isLocked = _appState.isCropLocked;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================================
                // 1. CROP SELECTOR CARD WITH CROP LOCKING & 5 CROPS
                // =========================================================
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t('select_crop'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            InkWell(
                              onTap: () {
                                _appState.toggleCropLock();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _appState.isCropLocked
                                          ? "🔒 Crop selection locked for season integrity."
                                          : "🔓 Crop selection unlocked! You can change crop type.",
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: _appState.isCropLocked ? Colors.green.shade800 : Colors.blue.shade800,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isLocked ? Colors.amber.shade100 : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isLocked ? Colors.amber.shade700 : Colors.blue.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isLocked ? Icons.lock : Icons.lock_open,
                                      size: 14,
                                      color: isLocked ? Colors.amber.shade900 : Colors.blue.shade900,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isLocked ? "CROP LOCKED" : "UNLOCKED",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLocked ? Colors.amber.shade900 : Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isLocked ? Colors.grey.shade100 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isLocked ? Colors.grey.shade400 : Colors.green.shade400),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCrop,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down, color: isLocked ? Colors.grey : Colors.green.shade800),
                              onChanged: isLocked
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        _appState.updateSelectedCrop(val);
                                      }
                                    },
                              items: const [
                                DropdownMenuItem(value: "Potato", child: Text("🥔 Potato (आलू)")),
                                DropdownMenuItem(value: "Tomato", child: Text("🍅 Tomato (टमाटर)")),
                                DropdownMenuItem(value: "Rice", child: Text("🌾 Rice (धान)")),
                                DropdownMenuItem(value: "Wheat", child: Text("🌾 Wheat (गेहूं)")),
                                DropdownMenuItem(value: "Corn", child: Text("🌽 Corn (मक्का)")),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(isLocked ? Icons.verified_user : Icons.info_outline, size: 16, color: Colors.green.shade800),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isLocked
                                    ? "Crop type '$selectedCrop' is locked for active field compliance."
                                    : "Select crop to dynamically arrange stage deadline schedules.",
                                style: TextStyle(fontSize: 11, color: Colors.black.withValues(alpha: 0.6)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Simulated System Date Switcher
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_calendar_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('simulated_date'), style: const TextStyle(fontSize: 10, color: Colors.black54)),
                            Text(_formatDate(systemDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: systemDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 120)),
                            lastDate: DateTime.now().add(const Duration(days: 120)),
                          );
                          if (picked != null) {
                            _appState.setSimulatedSystemDate(picked);
                          }
                        },
                        child: const Text("Change Date", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================================
                // 2. 5 CROP STAGES TIMELINE CARDS (UP TO 5 PHOTOS PER STAGE)
                // =========================================================
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    final isWithinRange = stage.isDateWithinRange(systemDate);
                    final isUploaded = stage.isUploaded;
                    final isExpired = systemDate.isAfter(stage.endDate);
                    final isPending = systemDate.isBefore(stage.startDate);

                    Color cardBorder;
                    String statusText;
                    Color statusBg;

                    if (isUploaded) {
                      cardBorder = Colors.green.shade600;
                      statusText = "${stage.photoCount}/5 Photos";
                      statusBg = Colors.green.shade700;
                    } else if (isWithinRange) {
                      cardBorder = Colors.blue.shade600;
                      statusText = t('status_active');
                      statusBg = Colors.blue.shade600;
                    } else if (isExpired) {
                      cardBorder = Colors.grey.shade400;
                      statusText = t('status_expired');
                      statusBg = Colors.red.shade400;
                    } else {
                      cardBorder = Colors.grey.shade300;
                      statusText = t('status_locked');
                      statusBg = Colors.orange;
                    }

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: cardBorder, width: isWithinRange || isUploaded ? 2.0 : 1.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Stage Name & Status Badge
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isUploaded
                                      ? Colors.green.shade700
                                      : (isWithinRange ? Colors.blue.shade700 : Colors.grey),
                                  child: isUploaded
                                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                                      : Text(
                                          "${stage.stageNumber}",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _langService.isHindi ? stage.stageNameHi : stage.stageNameEn,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Deadline Date Window Box
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.date_range, size: 16, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${t('deadline')}: ${_formatDate(stage.startDate)} - ${_formatDate(stage.endDate)}",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 5-Photo Gallery Grid Preview & "+" Add Photo Icon Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Stage Field Photos (${stage.photoCount}/5)",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    if (stage.photoCount > 0)
                                      Text(
                                        "Geo-Tagged (${stage.latitude?.toStringAsFixed(3)}, ${stage.longitude?.toStringAsFixed(3)})",
                                        style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                SizedBox(
                                  height: 72,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      // Render existing captured photos thumbnails
                                      for (int pIdx = 0; pIdx < stage.uploadedPhotoPaths.length; pIdx++)
                                        Container(
                                          margin: const EdgeInsets.only(right: 10),
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.green.shade400, width: 1.5),
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.photo_camera_back, color: Colors.green.shade800, size: 28),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      "Photo ${pIdx + 1}",
                                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Remove photo option icon button
                                              Positioned(
                                                top: 2,
                                                right: 2,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _appState.removeCropStagePhoto(selectedCrop, stage.stageNumber, pIdx);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(2),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.redAccent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // "+" Add Photo Button (If under 5 photos limit)
                                      if (!stage.isMaxPhotos && (isWithinRange || isUploaded))
                                        GestureDetector(
                                          onTap: () => _handleUploadStagePhoto(stage, selectedCrop),
                                          child: Container(
                                            width: 72,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.blue.shade400, width: 1.8, style: BorderStyle.solid),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_a_photo_rounded, color: Colors.blue.shade800, size: 26),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "+ Photo",
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
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

                            const SizedBox(height: 14),

                            // Submit Stage Photos Button
                            if (stage.photoCount > 0)
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleSubmitStagePhotos(stage, selectedCrop),
                                  icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                                  label: Text(
                                    "Submit Stage ${stage.stageNumber} Photos (${stage.photoCount}/5)",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade800,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: isWithinRange
                                      ? () => _handleUploadStagePhoto(stage, selectedCrop)
                                      : () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isPending
                                                    ? "Capture window opens on ${_formatDate(stage.startDate)}. Upload not allowed yet!"
                                                    : "Deadline passed on ${_formatDate(stage.endDate)}. Upload window closed!",
                                              ),
                                              backgroundColor: Colors.red.shade700,
                                            ),
                                          );
                                        },
                                  icon: Icon(isWithinRange ? Icons.add_a_photo : Icons.lock, size: 18),
                                  label: Text(
                                    isWithinRange
                                        ? "+ Add First Photo (0/5)"
                                        : (isPending ? "Window Opens ${_formatDate(stage.startDate)}" : "Deadline Expired"),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isWithinRange ? Colors.blue.shade800 : Colors.grey.shade400,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
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
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../widgets/quality_camera_screen.dart';

class UploadStageScreen extends StatefulWidget {
  final String farmId;
  const UploadStageScreen({super.key, required this.farmId});

  @override
  State<UploadStageScreen> createState() => _UploadStageScreenState();
}

class _UploadStageScreenState extends State<UploadStageScreen> {
  File? _selectedImage;
  Position? _currentPosition;
  double _blurScore = 0.0;
  bool _isAutoCaptured = false;
  bool _isSubmitting = false;

  Future<void> _captureImage() async {
    final QualityCameraResult? result = await Navigator.push<QualityCameraResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const QualityCameraScreen(
          title: "Crop Stage Inspection",
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedImage = File(result.imagePath);
        _blurScore = result.blurScore;
        _isAutoCaptured = result.isAutoCaptured;
        _currentPosition = Position(
          longitude: result.longitude,
          latitude: result.latitude,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      });
    }
  }

  Future<void> _submitData() async {
    if (_selectedImage == null || _currentPosition == null) return;
    setState(() => _isSubmitting = true);

    try {
      final request = http.MultipartRequest("POST", Uri.parse(ApiConstants.uploadStage));
      request.fields['farm_id'] = widget.farmId;
      request.fields['latitude'] = _currentPosition!.latitude.toString();
      request.fields['longitude'] = _currentPosition!.longitude.toString();
      request.fields['blurriness_score'] = _blurScore.toString();
      request.fields['is_auto_captured'] = _isAutoCaptured.toString();
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stage photo uploaded with GPS tags & AI quality validation!")),
        );
        Navigator.pop(context);
      }
    } catch (_) {}
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Crop Photo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _selectedImage != null
                  ? Column(
                      children: [
                        Expanded(child: Image.file(_selectedImage!, fit: BoxFit.cover)),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: Icon(_isAutoCaptured ? Icons.auto_awesome : Icons.check_circle, color: Colors.white, size: 16),
                          label: Text("Sharpness: ${_blurScore.toInt()}% | ${_isAutoCaptured ? 'Auto-captured' : 'Manual'}"),
                          backgroundColor: Colors.green.shade800,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : Center(
                      child: ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Open Automated Camera"),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            if (_currentPosition != null)
              Text("GPS: ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_selectedImage != null && !_isSubmitting) ? _submitData : null,
              child: _isSubmitting ? const CircularProgressIndicator() : const Text("Upload Stage Inspection"),
            )
          ],
        ),
      ),
    );
  }
}
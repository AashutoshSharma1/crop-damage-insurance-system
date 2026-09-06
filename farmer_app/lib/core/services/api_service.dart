import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Fetch Field Officer telemetry dashboard data from backend
  Future<Map<String, dynamic>?> fetchOfficerDashboard(String officerId) async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/officer/dashboard/$officerId");
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("ApiService fetchOfficerDashboard error (fallback mode): $e");
    }
    return null;
  }

  /// Update insurance claim status on backend database
  Future<bool> updateClaimStatus({
    required String claimId,
    required String status,
    required String officerId,
    String? remarks,
  }) async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/claims/update-status");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "claim_id": claimId,
          "status": status,
          "officer_id": officerId,
          "remarks": remarks ?? "Status updated by officer",
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("ApiService updateClaimStatus error: $e");
      return false;
    }
  }

  /// Bind captured field photo to claim in backend database
  Future<bool> attachClaimPhoto({
    required String claimId,
    required String photoUrl,
    String officerId = "OFFICER_201",
  }) async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/claims/add-photo");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "claim_id": claimId,
          "photo_url": photoUrl,
          "officer_id": officerId,
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("ApiService attachClaimPhoto error: $e");
      return false;
    }
  }

  /// Submit new insurance claim to backend API & Supabase database
  Future<bool> submitClaim({
    required String farmerId,
    required String farmerName,
    required String damageReason,
    required String description,
    required List<String> photoUrls,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.submitClaim);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "farmer_id": farmerId,
          "farmer_name": farmerName,
          "damage_reason": damageReason,
          "description": description,
          "photo_urls": photoUrls,
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("ApiService submitClaim error: $e");
      return false;
    }
  }
}


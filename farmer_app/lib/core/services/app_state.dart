import 'package:flutter/material.dart';
import '../models/farmer_model.dart';
import '../models/claim_model.dart';
import '../models/crop_stage_model.dart';
import '../models/weather_model.dart';
import 'api_service.dart';


enum UserRole { loggedOut, farmer, fieldOfficer }

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;

  AppState._internal() {
    _initDefaultData();
  }

  UserRole _currentUserRole = UserRole.loggedOut; // Default to login screen
  UserRole get currentUserRole => _currentUserRole;

  DateTime _simulatedSystemDate = DateTime.now();
  DateTime get simulatedSystemDate => _simulatedSystemDate;

  void setSimulatedSystemDate(DateTime date) {
    _simulatedSystemDate = date;
    notifyListeners();
  }

  void loginAsFarmer() {
    _currentUserRole = UserRole.farmer;
    notifyListeners();
  }

  void loginAsFieldOfficer() {
    _currentUserRole = UserRole.fieldOfficer;
    notifyListeners();
  }

  void signOut() {
    _currentUserRole = UserRole.loggedOut;
    notifyListeners();
  }

  // Active Field Officer Details
  String officerId = "OFFICER_201";
  String officerName = "Inspector D. Sharma";
  String officerZone = "Karnal North Zone";

  // Active Farmer Profile
  late FarmerModel activeFarmer;

  // Directory of Farmers for Field Officer Portal
  List<FarmerModel> registeredFarmers = [];

  // Weather Data
  late WeatherModel currentWeather;

  // Active Insurance Claims List
  List<ClaimModel> claimsList = [];

  // Crop Stages Map key: cropName
  Map<String, List<CropStageModel>> cropStagesMap = {};

  void _initDefaultData() {
    activeFarmer = FarmerModel(
      id: "FARMER_101",
      name: "Rajesh Kumar",
      email: "rajesh.farmer@agri.in",
      phone: "+91 98765 43210",
      aadhaar: "5412-8901-3456",
      residentialAddress: "House No. 42, Village Rampur, District Karnal, Haryana",
      fieldAddress: "Khasra No. 114/2, North Rampur Fields, Karnal",
      latitude: 29.6857,
      longitude: 76.9905,
      landAreaAcres: 4.2,
      selectedCrop: "Wheat",
      polygonBoundary: [
        [29.6865, 76.9895],
        [29.6870, 76.9915],
        [29.6848, 76.9920],
        [29.6845, 76.9898],
      ],
    );

    registeredFarmers = [
      activeFarmer,
      FarmerModel(
        id: "FARMER_102",
        name: "Suresh Singh",
        email: "suresh.singh@agri.in",
        phone: "+91 98123 76543",
        aadhaar: "8765-4321-9012",
        residentialAddress: "Village Bhainswal, Sonipat, Haryana",
        fieldAddress: "Khasra No. 88, Sonipat Agricultural Zone",
        latitude: 28.9931,
        longitude: 77.0151,
        landAreaAcres: 6.5,
        selectedCrop: "Paddy",
        polygonBoundary: [
          [28.9940, 77.0140],
          [28.9945, 77.0160],
          [28.9920, 77.0165],
          [28.9918, 77.0142],
        ],
      ),
      FarmerModel(
        id: "FARMER_103",
        name: "Anita Devi",
        email: "anita.devi@agri.in",
        phone: "+91 97234 56789",
        aadhaar: "3412-9087-6543",
        residentialAddress: "Village Assandh, Karnal, Haryana",
        fieldAddress: "Plot No. 15, Assandh Farms",
        latitude: 29.5215,
        longitude: 76.6022,
        landAreaAcres: 3.0,
        selectedCrop: "Mustard",
        polygonBoundary: [
          [29.5225, 76.6012],
          [29.5230, 76.6032],
          [29.5205, 76.6035],
          [29.5200, 76.6015],
        ],
      ),
    ];

    currentWeather = WeatherModel(
      temperature: 28.5,
      humidity: 64.0,
      rainfallMm: 12.5,
      windSpeedKmh: 14.2,
      condition: "Partly Cloudy / आंशिक बादल",
      forecast5Days: [
        DailyForecast(dayName: "Mon (सोम)", tempHigh: 29.0, tempLow: 21.0, rainChancePct: 20, condition: "Sunny", icon: "☀️"),
        DailyForecast(dayName: "Tue (मंगल)", tempHigh: 30.2, tempLow: 22.1, rainChancePct: 15, condition: "Clear", icon: "🌤️"),
        DailyForecast(dayName: "Wed (बुध)", tempHigh: 27.5, tempLow: 20.4, rainChancePct: 65, condition: "Rain Shower", icon: "🌧️"),
        DailyForecast(dayName: "Thu (गुरु)", tempHigh: 26.0, tempLow: 19.8, rainChancePct: 80, condition: "Heavy Rain", icon: "⛈️"),
        DailyForecast(dayName: "Fri (शुक्र)", tempHigh: 28.1, tempLow: 21.5, rainChancePct: 30, condition: "Cloudy", icon: "⛅"),
      ],
    );

    // Crop Locking State
    isCropLocked = true;

    // Initial Crop Stages (5 stages per crop with deadline date windows)
    final now = DateTime.now();

    cropStagesMap["Potato"] = [
      CropStageModel(stageNumber: 1, stageNameEn: "Stage 1: Sowing & Sprouting", stageNameHi: "चरण 1: बीजाई एवं अंकुरण", startDate: now.subtract(const Duration(days: 15)), endDate: now.add(const Duration(days: 5)), uploadedPhotoPaths: ["asset_potato_1"], uploadedAt: now.subtract(const Duration(days: 5)), latitude: 29.6857, longitude: 76.9905),
      CropStageModel(stageNumber: 2, stageNameEn: "Stage 2: Vegetative & Stolon", stageNameHi: "चरण 2: वानस्पतिक वृद्धि व स्टोलन", startDate: now.add(const Duration(days: 6)), endDate: now.add(const Duration(days: 30))),
      CropStageModel(stageNumber: 3, stageNameEn: "Stage 3: Tuber Initiation", stageNameHi: "चरण 3: कंद बनना (ट्यूबर प्रारंभ)", startDate: now.add(const Duration(days: 31)), endDate: now.add(const Duration(days: 60))),
      CropStageModel(stageNumber: 4, stageNameEn: "Stage 4: Tuber Bulking", stageNameHi: "चरण 4: आलू का बढ़ना (बुलकिंग)", startDate: now.add(const Duration(days: 61)), endDate: now.add(const Duration(days: 85))),
      CropStageModel(stageNumber: 5, stageNameEn: "Stage 5: Maturation & Harvesting", stageNameHi: "चरण 5: परिपक्वता एवं खुदाई", startDate: now.add(const Duration(days: 86)), endDate: now.add(const Duration(days: 105))),
    ];

    cropStagesMap["Tomato"] = [
      CropStageModel(stageNumber: 1, stageNameEn: "Stage 1: Nursery & Transplanting", stageNameHi: "चरण 1: पौधशाला व रोपाई", startDate: now.subtract(const Duration(days: 10)), endDate: now.add(const Duration(days: 5))),
      CropStageModel(stageNumber: 2, stageNameEn: "Stage 2: Vegetative Growth", stageNameHi: "चरण 2: पौधे का विकास", startDate: now.add(const Duration(days: 6)), endDate: now.add(const Duration(days: 30))),
      CropStageModel(stageNumber: 3, stageNameEn: "Stage 3: Flowering & Fruit Set", stageNameHi: "चरण 3: फूल एवं फल सेट", startDate: now.add(const Duration(days: 31)), endDate: now.add(const Duration(days: 60))),
      CropStageModel(stageNumber: 4, stageNameEn: "Stage 4: Fruit Development & Ripening", stageNameHi: "चरण 4: फल विकास व पकना", startDate: now.add(const Duration(days: 61)), endDate: now.add(const Duration(days: 85))),
      CropStageModel(stageNumber: 5, stageNameEn: "Stage 5: Harvesting", stageNameHi: "चरण 5: तुड़ाई व कटाई", startDate: now.add(const Duration(days: 86)), endDate: now.add(const Duration(days: 100))),
    ];

    cropStagesMap["Rice"] = [
      CropStageModel(stageNumber: 1, stageNameEn: "Stage 1: Nursery & Transplanting", stageNameHi: "चरण 1: पौधशाला एवं रोपाई", startDate: now.subtract(const Duration(days: 15)), endDate: now.add(const Duration(days: 5))),
      CropStageModel(stageNumber: 2, stageNameEn: "Stage 2: Vegetative Tillering", stageNameHi: "चरण 2: कल्ले निकलना", startDate: now.add(const Duration(days: 6)), endDate: now.add(const Duration(days: 30))),
      CropStageModel(stageNumber: 3, stageNameEn: "Stage 3: Panicle Initiation", stageNameHi: "चरण 3: बाली बनना (पैनिकल्स)", startDate: now.add(const Duration(days: 31)), endDate: now.add(const Duration(days: 60))),
      CropStageModel(stageNumber: 4, stageNameEn: "Stage 4: Flowering & Milky Stage", stageNameHi: "चरण 4: फूल आना एवं दूध भरना", startDate: now.add(const Duration(days: 61)), endDate: now.add(const Duration(days: 85))),
      CropStageModel(stageNumber: 5, stageNameEn: "Stage 5: Dough Stage & Harvest", stageNameHi: "चरण 5: दाना सख्त होना एवं कटाई", startDate: now.add(const Duration(days: 86)), endDate: now.add(const Duration(days: 105))),
    ];

    cropStagesMap["Wheat"] = [
      CropStageModel(stageNumber: 1, stageNameEn: "Stage 1: Sowing & Germination", stageNameHi: "चरण 1: बीजाई एवं अंकुरण", startDate: now.subtract(const Duration(days: 20)), endDate: now.subtract(const Duration(days: 5)), uploadedPhotoPaths: ["asset_wheat_1"], uploadedAt: now.subtract(const Duration(days: 10)), latitude: 29.6857, longitude: 76.9905),
      CropStageModel(stageNumber: 2, stageNameEn: "Stage 2: Crown Root & Tillering", stageNameHi: "चरण 2: मुकुट जड़ एवं कल्ले निकलना", startDate: now.subtract(const Duration(days: 4)), endDate: now.add(const Duration(days: 10))),
      CropStageModel(stageNumber: 3, stageNameEn: "Stage 3: Jointing & Booting", stageNameHi: "चरण 3: गांठ बनना एवं बूटिंग", startDate: now.add(const Duration(days: 11)), endDate: now.add(const Duration(days: 25))),
      CropStageModel(stageNumber: 4, stageNameEn: "Stage 4: Flowering & Grain Filling", stageNameHi: "चरण 4: पुष्पन एवं दाना भरना", startDate: now.add(const Duration(days: 26)), endDate: now.add(const Duration(days: 45))),
      CropStageModel(stageNumber: 5, stageNameEn: "Stage 5: Ripening & Harvesting", stageNameHi: "चरण 5: पकना एवं कटाई", startDate: now.add(const Duration(days: 46)), endDate: now.add(const Duration(days: 65))),
    ];

    cropStagesMap["Corn"] = [
      CropStageModel(stageNumber: 1, stageNameEn: "Stage 1: Sowing & Emergence", stageNameHi: "चरण 1: बीजाई एवं अंकुरण", startDate: now.subtract(const Duration(days: 12)), endDate: now.add(const Duration(days: 3))),
      CropStageModel(stageNumber: 2, stageNameEn: "Stage 2: Vegetative Growth (V6-V12)", stageNameHi: "चरण 2: वानस्पतिक विकास (V6-V12)", startDate: now.add(const Duration(days: 4)), endDate: now.add(const Duration(days: 25))),
      CropStageModel(stageNumber: 3, stageNameEn: "Stage 3: Tasseling & Silking", stageNameHi: "चरण 3: मंजर व सिल्क निकलना", startDate: now.add(const Duration(days: 26)), endDate: now.add(const Duration(days: 50))),
      CropStageModel(stageNumber: 4, stageNameEn: "Stage 4: Blister & Dough Stage", stageNameHi: "चरण 4: दाना भरना (दूध व डो)", startDate: now.add(const Duration(days: 51)), endDate: now.add(const Duration(days: 70))),
      CropStageModel(stageNumber: 5, stageNameEn: "Stage 5: Physiological Maturity & Harvest", stageNameHi: "चरण 5: परिपक्वता एवं कटाई", startDate: now.add(const Duration(days: 71)), endDate: now.add(const Duration(days: 90))),
    ];

    // Seed multi-farmer claims with 72h inspection timestamps
    claimsList = [
      ClaimModel(
        id: "CLM-2026-891",
        farmerId: activeFarmer.id,
        farmerName: activeFarmer.name,
        damageReason: "Unseasonal Hailstorm & Heavy Rain (ओलावृष्टि)",
        description: "Heavy hailstorm damaged Wheat crop at jointing stage. 40% lodging of crops noticed in north field zone.",
        photoPaths: [
          "assets/claims/proof_1.jpg",
          "assets/claims/proof_2.jpg",
          "assets/claims/proof_3.jpg",
          "assets/claims/proof_4.jpg",
          "assets/claims/proof_5.jpg",
        ],
        dateSubmitted: DateTime.now().subtract(const Duration(hours: 14)),
        status: ClaimStatus.submitted,
      ),
      ClaimModel(
        id: "CLM-2026-442",
        farmerId: "FARMER_102",
        farmerName: "Suresh Singh",
        damageReason: "Insect & Pest Attack (कीट प्रकोप)",
        description: "Stem borer infestation spotted across 2 acres. Foliage severely damaged.",
        photoPaths: [
          "assets/claims/proof_1.jpg",
          "assets/claims/proof_2.jpg",
          "assets/claims/proof_3.jpg",
          "assets/claims/proof_4.jpg",
          "assets/claims/proof_5.jpg",
        ],
        dateSubmitted: DateTime.now().subtract(const Duration(hours: 48)),
        status: ClaimStatus.submitted,
      ),
      ClaimModel(
        id: "CLM-2026-105",
        farmerId: "FARMER_103",
        farmerName: "Anita Devi",
        damageReason: "Flood & Waterlogging (जलभराव)",
        description: "Field flooded due to continuous heavy downpour. Standing water level up to 2 feet.",
        photoPaths: [
          "assets/claims/proof_1.jpg",
          "assets/claims/proof_2.jpg",
          "assets/claims/proof_3.jpg",
          "assets/claims/proof_4.jpg",
          "assets/claims/proof_5.jpg",
        ],
        dateSubmitted: DateTime.now().subtract(const Duration(hours: 68)),
        status: ClaimStatus.verified,
        officerNotes: "Field satellite and ground photo verification completed by Inspector D. Sharma.",
        estimatedPayout: 32000.0,
      ),
    ];
  }


  bool isCropLocked = true;

  void toggleCropLock() {
    isCropLocked = !isCropLocked;
    notifyListeners();
  }

  void lockCrop() {
    isCropLocked = true;
    notifyListeners();
  }

  void updateSelectedCrop(String crop) {
    if (!isCropLocked) {
      activeFarmer = activeFarmer.copyWith(selectedCrop: crop);
      notifyListeners();
    }
  }

  void updateFarmerProfile(FarmerModel updated) {
    activeFarmer = updated;
    int idx = registeredFarmers.indexWhere((f) => f.id == updated.id);
    if (idx != -1) {
      registeredFarmers[idx] = updated;
    }
    notifyListeners();
  }

  void addCropStagePhoto(String crop, int stageNumber, String photoPath, double lat, double lng) {
    if (cropStagesMap.containsKey(crop)) {
      final list = cropStagesMap[crop]!;
      int idx = list.indexWhere((s) => s.stageNumber == stageNumber);
      if (idx != -1) {
        list[idx].addPhoto(photoPath);
        list[idx].uploadedAt = DateTime.now();
        list[idx].latitude = lat;
        list[idx].longitude = lng;
        notifyListeners();
      }
    }
  }

  void removeCropStagePhoto(String crop, int stageNumber, int photoIndex) {
    if (cropStagesMap.containsKey(crop)) {
      final list = cropStagesMap[crop]!;
      int idx = list.indexWhere((s) => s.stageNumber == stageNumber);
      if (idx != -1) {
        list[idx].removePhoto(photoIndex);
        notifyListeners();
      }
    }
  }

  void submitInsuranceClaim({
    required String reason,
    required String description,
    required List<String> photos,
  }) {
    final newClaim = ClaimModel(
      id: "CLM-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      farmerId: activeFarmer.id,
      farmerName: activeFarmer.name,
      damageReason: reason,
      description: description,
      photoPaths: photos,
      dateSubmitted: DateTime.now(),
      status: ClaimStatus.submitted,
    );
    claimsList.insert(0, newClaim);
    notifyListeners();
  }

  void updateClaimStatus(String claimId, ClaimStatus newStatus, {String? notes, double? payout}) {
    int idx = claimsList.indexWhere((c) => c.id == claimId);
    if (idx != -1) {
      claimsList[idx] = claimsList[idx].copyWith(
        status: newStatus,
        officerNotes: notes ?? claimsList[idx].officerNotes,
        estimatedPayout: payout ?? claimsList[idx].estimatedPayout,
      );
      notifyListeners();

      // Sync with backend API
      ApiService().updateClaimStatus(
        claimId: claimId,
        status: newStatus.name,
        officerId: officerId,
        remarks: notes,
      );
    }
  }

  void addClaimPhoto(String claimId, String photoPath) {
    int idx = claimsList.indexWhere((c) => c.id == claimId);
    if (idx != -1) {
      final updatedPhotos = List<String>.from(claimsList[idx].photoPaths)..add(photoPath);
      claimsList[idx] = claimsList[idx].copyWith(photoPaths: updatedPhotos);
      notifyListeners();

      // Sync captured photo with backend API
      ApiService().attachClaimPhoto(
        claimId: claimId,
        photoUrl: photoPath,
        officerId: officerId,
      );
    }
  }
}


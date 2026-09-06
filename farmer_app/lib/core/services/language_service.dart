import 'package:flutter/material.dart';

enum AppLanguage { english, hindi }

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isHindi => _currentLanguage == AppLanguage.hindi;

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == AppLanguage.english ? AppLanguage.hindi : AppLanguage.english;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[_currentLanguage]?[key] ?? _localizedStrings[AppLanguage.english]?[key] ?? key;
  }

  static const Map<AppLanguage, Map<String, String>> _localizedStrings = {
    AppLanguage.english: {
      'app_title': 'Crop Insurance & Field Telemetry',
      'hi': 'Hi',
      'sign_out': 'Sign Out',
      'switch_lang': 'हिंदी',
      'farmer_login': 'Farmer Portal Login',
      'officer_login': 'Field Officer / Admin Portal',
      'email': 'Email ID',
      'password': 'Password',
      'login_btn': 'Login to Portal',
      'quick_farmer_login': 'Quick Login as Farmer',
      'quick_officer_login': 'Quick Login as Officer',
      'role_farmer': 'Farmer',
      'role_officer': 'Field Officer / Admin',

      // Nav Tabs
      'nav_home': 'Home',
      'nav_stages': 'Crop Stages',
      'nav_claim': 'File Claim',
      'nav_insurance': 'Insurance',
      'nav_profile': 'Profile',

      // Home Screen
      'field_map': 'Field Location & Boundary Overview',
      'field_size': 'Total Field Area: 4.2 Acres',
      'coordinates': 'Center Coordinates',
      'weather_title': 'Live Weather Telemetry & 5-Day Forecast',
      'current_temp': 'Temperature',
      'humidity': 'Humidity',
      'rainfall': 'Rainfall',
      'wind': 'Wind Speed',
      'forecast': '5-Day Forecast',
      'crop_condition_title': 'Crop Vulnerability & Health Analysis',
      'status_good': 'GOOD CONDITION',
      'status_warning': 'MODERATE RISK',
      'status_bad': 'HIGH RISK / DAMAGE ALERT',
      'msg_good': 'Weather parameters (Temp 28°C, Humidity 62%, Rain 12mm) are optimal for healthy crop growth. Low pest/disease threat.',
      'msg_warning': 'Humidity is high (84%) with moderate rainfall (45mm). Elevated risk of fungal infections and soil saturation.',
      'msg_bad': 'Excessive rainfall detected (110mm) with extreme humidity (92%). Severe risk of crop flooding and pest infestation!',

      // Crop Stages Screen
      'select_crop': 'Select Crop Type:',
      'crop_potato': 'Potato (आलू)',
      'crop_tomato': 'Tomato (टमाटर)',
      'crop_rice': 'Rice (धान)',
      'crop_wheat': 'Wheat (गेहूं)',
      'crop_corn': 'Corn (मक्का)',
      'crop_locked_title': 'Crop Selected & Locked',
      'crop_locked_msg': 'Crop type is locked to maintain field compliance and stage schedules.',
      'stage_photo_required': 'Upload up to 5 photos for each stage within the deadline window.',
      'photos_captured': 'Photos Uploaded:',
      'submit_stage_photos': 'Submit Stage Photos',
      'add_more_photos': 'Add Photo',
      'deadline': 'Deadline Window',
      'status_completed': 'Completed',
      'status_active': 'Capture Window Open',
      'status_locked': 'Window Pending',
      'status_expired': 'Deadline Passed',
      'capture_photo': 'Capture Photo',
      'deadline_notice': 'Photos must be clicked strictly within the date range window. Outside dates are disabled.',
      'simulated_date': 'Active System Date for Deadline Verification',

      // File Claim Screen
      'file_claim_title': 'Raise Crop Damage Insurance Claim',
      'damage_reason': 'Reason for Crop Damage:',
      'reason_flood': 'Flood / Waterlogging (बाढ़)',
      'reason_insects': 'Insects & Pest Attack (कीट प्रकोप)',
      'reason_drought': 'Drought / Water Deficiency (सूखा)',
      'reason_hailstorm': 'Hailstorm / Unseasonal Storm (ओलावृष्टि)',
      'reason_heavy_rain': 'Heavy Rain & Wind (भारी बारिश)',
      'reason_disease': 'Crop Disease Outbreak (बीमारी)',
      'description_hint': 'Explain the exact crop damage condition in detail...',
      'upload_5_photos': 'Upload 5 Field Photos of Damaged Crop:',
      'photo_slot': 'Photo',
      'add_photo': 'Add Photo',
      'submit_claim_btn': 'Submit Insurance Claim',
      'photos_required_err': 'Please upload exactly 5 photos of the damaged field!',
      'claim_success': 'Insurance Claim submitted successfully! Field officer assigned.',

      // Insurance Screen
      'insurance_title': 'Insurance Claim Status & History',
      'active_claims': 'Active Claims',
      'historic_claims': 'Resolved History',
      'claim_id': 'Claim ID',
      'status_submitted': 'Claim Submitted',
      'status_verified': 'Officer Verified',
      'status_assessed': 'Loss Assessed',
      'status_approved': 'Payout Disbursed',

      // Profile Screen
      'profile_title': 'Farmer & Land Profile Details',
      'farmer_name': 'Farmer Name',
      'aadhaar_no': 'Aadhaar Card Number',
      'phone_no': 'Phone Number',
      'res_address': 'Residential Address',
      'field_address': 'Field / Village Location',
      'lat_lng': 'Field Latitude & Longitude',
      'land_area': 'Land Holdings (Acres)',
      'edit_profile': 'Edit Profile Details',
      'save_profile': 'Save Profile',

      // Field Officer Admin Portal
      'officer_dashboard_title': 'Field Officer Verification Portal',
      'zone_of_work': 'Zone of Work',
      'map_card_title': 'Allotted Fields Boundary Overview (OSM Map)',
      'map_card_sub': 'Click map to open interactive OpenStreetMap with allotted field polygons',
      'stat_total_tasks': 'Total Tasks Allotted',
      'stat_pending_tasks': 'Pending Tasks',
      'stat_verified_tasks': 'Verified Tasks',
      'lookup_location': 'Look Up Field Location',
      'deadline_timer': '72h Inspection Deadline',
      'registered_farmers': 'Registered Farmers Directory',
      'col_name': 'Farmer Name',
      'col_phone': 'Phone / Aadhaar',
      'col_location': 'Village & Coordinates',
      'col_crop': 'Crop & Stage Progress',
      'col_health': 'Health Status',
      'col_claims': 'Pending Claims',
      'col_action': 'Actions',
      'inspect_claim': 'Inspect Claim',
      'approve_claim': 'Approve Payout',
      'reject_claim': 'Reject Claim',
      'reinspect': 'Request Field Re-Inspection',
      'claim_inspection_title': 'Insurance Claim Inspection Modal',
      'photos_submitted': 'Submitted Proof Photos (5 Photos)',
      'officer_profile_title': 'Field Officer Profile',
      'officer_role': 'Senior Crop & Insurance Inspector',
      'capture_field_photo': 'Capture Field Photo',
      'field_photos_attached': 'Officer Field Inspection Photos',
    },
    AppLanguage.hindi: {
      'app_title': 'फसल बीमा एवं खेत निगरानी',
      'hi': 'नमस्ते',
      'sign_out': 'साइन आउट',
      'switch_lang': 'English',
      'farmer_login': 'किसान पोर्टल लॉगिन',
      'officer_login': 'क्षेत्र अधिकारी / एडमिन पोर्टल',
      'email': 'ईमेल आईडी',
      'password': 'पासवर्ड',
      'login_btn': 'पोर्टल में लॉगिन करें',
      'quick_farmer_login': 'किसान के रूप में त्वरित लॉगिन',
      'quick_officer_login': 'अधिकारी के रूप में त्वरित लॉगिन',
      'role_farmer': 'किसान',
      'role_officer': 'क्षेत्र अधिकारी / एडमिन',

      // Nav Tabs
      'nav_home': 'होम',
      'nav_stages': 'फसल चरण',
      'nav_claim': 'दावा दर्ज करें',
      'nav_insurance': 'बीमा दावे',
      'nav_profile': 'प्रोफाइल',

      // Home Screen
      'field_map': 'खेत का नक्शा एवं सीमा अवलोकन',
      'field_size': 'कुल खेत का क्षेत्रफल: 4.2 एकड़',
      'coordinates': 'केंद्र के निर्देशांक',
      'weather_title': 'लाइव मौसम विवरण एवं 5-दिवसीय पूर्वानुमान',
      'current_temp': 'तापमान',
      'humidity': 'आर्द्रता (नमी)',
      'rainfall': 'वर्षा (मिमी)',
      'wind': 'हवा की गति',
      'forecast': '5-दिवसीय पूर्वानुमान',
      'crop_condition_title': 'फसल स्वास्थ्य एवं मौसम प्रभाव विश्लेषण',
      'status_good': 'उत्कृष्ट स्थिति (Good)',
      'status_warning': 'मध्यम जोखिम (Warning)',
      'status_bad': 'उच्च जोखिम / क्षति चेतावनी (Bad)',
      'msg_good': 'मौसम के आंकड़े (तापमान 28°C, नमी 62%, वर्षा 12mm) फसल के इष्टतम विकास के लिए बहुत अनुकूल हैं। कीटों का खतरा कम है।',
      'msg_warning': 'आर्द्रता अधिक है (84%) और मध्यम वर्षा (45mm) हुई है। फंगल संक्रमण एवं मिट्टी में पानी जमा होने का जोखिम बढ़ गया है।',
      'msg_bad': 'अत्यधिक भारी बारिश (110mm) एवं उच्च नमी (92%) दर्ज की गई है। खेत में पानी भरने एवं फसल नष्ट होने का गंभीर खतरा!',

      // Crop Stages Screen
      'select_crop': 'फसल का प्रकार चुनें:',
      'crop_potato': 'आलू (Potato)',
      'crop_tomato': 'टमाटर (Tomato)',
      'crop_rice': 'धान / चावल (Rice)',
      'crop_wheat': 'गेहूं (Wheat)',
      'crop_paddy': 'धान (Paddy / Rice)',
      'crop_mustard': 'सरसों (Mustard)',
      'crop_cotton': 'कपास (Cotton)',
      'crop_sugarcane': 'गन्ना (Sugarcane)',
      'stage_photo_required': 'फसल चक्र में 5 फोटो आवश्यक हैं (समय सीमा के अंदर प्रति चरण 1 फोटो)',
      'deadline': 'अंतिम तिथि सीमा (Deadline)',
      'status_completed': 'फोटो अपलोड हो गई',
      'status_active': 'फोटो खींचने की सीमा चालू',
      'status_locked': 'समय सीमा अभी शुरू नहीं हुई',
      'status_expired': 'अंतिम तिथि समाप्त',
      'capture_photo': 'फोटो खींचें / अपलोड करें',
      'deadline_notice': 'फोटो केवल तय तारीख की सीमा के भीतर ही खींची जा सकती है। अन्य तारीखों पर बटन बंद रहेगा।',
      'simulated_date': 'सत्यापन के लिए सक्रिय प्रणाली तिथि',

      // File Claim Screen
      'file_claim_title': 'फसल क्षति बीमा दावा दर्ज करें',
      'damage_reason': 'फसल नुकसान का कारण:',
      'reason_flood': 'बाढ़ / जलभराव (Flood)',
      'reason_insects': 'कीट एवं कीट प्रकोप (Insects / Pest)',
      'reason_drought': 'सूखा / पानी की कमी (Drought)',
      'reason_hailstorm': 'ओलावृष्टि / बेमौसम तूफान (Hailstorm)',
      'reason_heavy_rain': 'भारी बारिश एवं तेज हवाएं (Heavy Rain)',
      'reason_disease': 'फसल बीमारी का फैलाव (Disease)',
      'description_hint': 'खेत में फसल के नुकसान का विस्तार से वर्णन करें...',
      'upload_5_photos': 'क्षतिग्रस्त फसल की 5 तस्वीरें अपलोड करें:',
      'photo_slot': 'फोटो',
      'add_photo': 'फोटो जोड़ें',
      'submit_claim_btn': 'बीमा दावा जमा करें',
      'photos_required_err': 'कृपया क्षतिग्रस्त खेत की पूरी 5 तस्वीरें अपलोड करें!',
      'claim_success': 'बीमा दावा सफलतापूर्वक दर्ज किया गया! क्षेत्र अधिकारी नियुक्त कर दिया गया है।',

      // Insurance Screen
      'insurance_title': 'बीमा दावे की स्थिति एवं इतिहास',
      'active_claims': 'सक्रिय दावे',
      'historic_claims': 'पुराने हल किए गए दावे',
      'claim_id': 'दावा संख्या (Claim ID)',
      'status_submitted': 'दावा जमा किया गया',
      'status_verified': 'अधिकारी द्वारा सत्यापित',
      'status_assessed': 'नुकसान का मूल्यांकन',
      'status_approved': 'बीमा राशि स्वीकृत',

      // Profile Screen
      'profile_title': 'किसान एवं कृषि भूमि विवरण',
      'farmer_name': 'किसान का नाम',
      'aadhaar_no': 'आधार कार्ड नंबर',
      'phone_no': 'फ़ोन नंबर',
      'res_address': 'आवासीय पता',
      'field_address': 'खेत का पता / गाँव',
      'lat_lng': 'खेत के अक्षांश एवं देशांतर (Lat/Lng)',
      'land_area': 'कुल कृषि भूमि (एकड़)',
      'edit_profile': 'विवरण संपादित करें',
      'save_profile': 'विवरण सुरक्षित करें',

      // Field Officer Admin Portal
      'officer_dashboard_title': 'क्षेत्र अधिकारी सत्यापन पोर्टल',
      'zone_of_work': 'कार्य क्षेत्र',
      'map_card_title': 'आवंटित खेतों का नक्शा (OSM मैप)',
      'map_card_sub': 'आवंटित खेतों का बहुभुज (Polygon) देखने के लिए क्लिक करें',
      'stat_total_tasks': 'कुल आवंटित कार्य',
      'stat_pending_tasks': 'लंबित कार्य',
      'stat_verified_tasks': 'सत्यापित कार्य',
      'lookup_location': 'खेत की लोकेशन देखें',
      'deadline_timer': '72-घंटे निरीक्षण समय सीमा',
      'registered_farmers': 'पंजीकृत किसानों की सूची',
      'col_name': 'किसान का नाम',
      'col_phone': 'फ़ोन / आधार',
      'col_location': 'गाँव एवं निर्देशांक',
      'col_crop': 'फसल एवं चरण प्रगति',
      'col_health': 'स्वास्थ्य स्थिति',
      'col_claims': 'लंबित दावे',
      'col_action': 'कार्रवाई',
      'inspect_claim': 'दावे की जांच करें',
      'approve_claim': 'राशि स्वीकृत करें',
      'reject_claim': 'अस्वीकार करें',
      'reinspect': 'पुनः जांच का अनुरोध करें',
      'claim_inspection_title': 'बीमा दावा निरीक्षण विंडो',
      'photos_submitted': 'जमा की गई 5 साक्ष्य तस्वीरें',
    }
  };
}

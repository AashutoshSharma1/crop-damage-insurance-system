class ApiConstants {
  // Update with your actual Supabase credentials
  static const String supabaseUrl = "https://ogvxhpbbygnexqafcalz.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ndnhocGJieWduZXhxYWZjYWx6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcxNTg4NzgsImV4cCI6MjEwMjczNDg3OH0.D8U2ZbT4JQyXQ3TJkcEQdHlx2dA9S2NrVyX58fbXgvI";

  // Backend Endpoints
  // Android Emulator -> http://10.0.2.2:8000
  // iOS Simulator     -> http://127.0.0.1:8000
  // Production Domain -> https://your-backend.com
  static const String baseUrl = "http://10.0.2.2:8000/api/v1";

  static const String evaluateFarm = "$baseUrl/crop-health/evaluate-farm";
  static const String uploadStage = "$baseUrl/crop-health/upload-stage";
  static const String submitClaim = "$baseUrl/claims/submit";
}


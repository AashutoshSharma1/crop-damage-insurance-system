import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';
import 'core/services/language_service.dart';
import 'core/services/app_state.dart';
import 'features/auth/login_screen.dart';
import 'features/farmer/presentation/farmer_main_layout.dart';
import 'features/officer/presentation/field_officer_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safe Supabase Initialization
  try {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      publishableKey: ApiConstants.supabaseAnonKey,
    );
  } catch (_) {}

  runApp(const CropInsuranceApp());
}

class CropInsuranceApp extends StatelessWidget {
  const CropInsuranceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    final appState = AppState();

    return ListenableBuilder(
      listenable: Listenable.merge([languageService, appState]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Crop Insurance System',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: _getHomeScreen(appState.currentUserRole),
        );
      },
    );
  }

  Widget _getHomeScreen(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return const FarmerMainLayout();
      case UserRole.fieldOfficer:
        return const FieldOfficerDashboard();
      case UserRole.loggedOut:
        return const LoginScreen();
    }
  }
}
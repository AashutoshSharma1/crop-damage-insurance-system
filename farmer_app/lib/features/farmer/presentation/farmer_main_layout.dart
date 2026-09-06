import 'package:flutter/material.dart';
import '../../../core/services/language_service.dart';
import '../../../core/services/app_state.dart';
import 'screens/farmer_home_screen.dart';
import 'screens/crop_stages_screen.dart';
import 'screens/file_claim_screen.dart';
import 'screens/insurance_claims_screen.dart';
import 'screens/farmer_profile_screen.dart';

class FarmerMainLayout extends StatefulWidget {
  const FarmerMainLayout({super.key});

  @override
  State<FarmerMainLayout> createState() => _FarmerMainLayoutState();
}

class _FarmerMainLayoutState extends State<FarmerMainLayout> {
  int _selectedIndex = 0;
  final LanguageService _langService = LanguageService();
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_langService, _appState]),
      builder: (context, _) {
        final t = _langService.translate;
        final farmer = _appState.activeFarmer;

        final List<Widget> pages = [
          const FarmerHomeScreen(),
          const CropStagesScreen(),
          const FileClaimScreen(),
          const InsuranceClaimsScreen(),
          const FarmerProfileScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green.shade800,
            foregroundColor: Colors.white,
            elevation: 2,
            title: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${t('hi')}, ${farmer.name}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${t('land_area')}: ${farmer.landAreaAcres} | ${farmer.selectedCrop}",
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Language Switch Button
              TextButton.icon(
                onPressed: () => _langService.toggleLanguage(),
                icon: const Icon(Icons.translate, color: Colors.amberAccent, size: 18),
                label: Text(
                  t('switch_lang'),
                  style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(width: 8),

              // Sign Out Button
              IconButton(
                onPressed: () => _appState.signOut(),
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: t('sign_out'),
              ),
              const SizedBox(width: 6),
            ],
          ),

          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.green.shade800,
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home_rounded),
                  label: t('nav_home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.grass_outlined),
                  activeIcon: const Icon(Icons.grass_rounded),
                  label: t('nav_stages'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.report_problem_outlined),
                  activeIcon: const Icon(Icons.report_problem_rounded),
                  label: t('nav_claim'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.verified_user_outlined),
                  activeIcon: const Icon(Icons.verified_user_rounded),
                  label: t('nav_insurance'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person_rounded),
                  label: t('nav_profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

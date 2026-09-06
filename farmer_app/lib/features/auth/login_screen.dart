import 'package:flutter/material.dart';
import '../../core/services/language_service.dart';
import '../../core/services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isOfficerRole = false;
  final _langService = LanguageService();
  final _appState = AppState();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "rajesh.farmer@agri.in");
    _passwordController = TextEditingController(text: "farmer123");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchRole(bool isOfficer) {
    setState(() {
      _isOfficerRole = isOfficer;
      if (isOfficer) {
        _emailController.text = "officer.karnal@agri.in";
        _passwordController.text = "officer123";
      } else {
        _emailController.text = "rajesh.farmer@agri.in";
        _passwordController.text = "farmer123";
      }
    });
  }

  void _performLogin() {
    if (_isOfficerRole) {
      _appState.loginAsFieldOfficer();
    } else {
      _appState.loginAsFarmer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_langService, _appState]),
      builder: (context, _) {
        final t = _langService.translate;
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade900,
                  Colors.green.shade700,
                  Colors.teal.shade900,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Top bar language toggle
                  Positioned(
                    top: 12,
                    right: 16,
                    child: ElevatedButton.icon(
                      onPressed: () => _langService.toggleLanguage(),
                      icon: const Icon(Icons.language, size: 18),
                      label: Text(_langService.isHindi ? "English" : "हिंदी"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),

                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Branding Badge
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(Icons.agriculture_rounded, size: 64, color: Colors.amberAccent),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('app_title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isOfficerRole ? t('officer_login') : t('farmer_login'),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Role Selector Segment Buttons
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _switchRole(false),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      decoration: BoxDecoration(
                                        color: !_isOfficerRole ? Colors.amber.shade700 : Colors.transparent,
                                        borderRadius: BorderRadius.circular(26),
                                        boxShadow: !_isOfficerRole
                                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.person, color: Colors.white, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            t('role_farmer'),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _switchRole(true),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      decoration: BoxDecoration(
                                        color: _isOfficerRole ? Colors.teal.shade700 : Colors.transparent,
                                        borderRadius: BorderRadius.circular(26),
                                        boxShadow: _isOfficerRole
                                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            t('role_officer'),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Glassmorphic Card Form
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: t('email'),
                                    prefixIcon: Icon(_isOfficerRole ? Icons.badge : Icons.email_outlined),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: t('password'),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _performLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isOfficerRole ? Colors.teal.shade900 : Colors.green.shade800,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      t('login_btn'),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),

                                // Quick 1-Click Login Shortcut Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          _switchRole(false);
                                          _appState.loginAsFarmer();
                                        },
                                        icon: const Icon(Icons.nature_people, size: 16),
                                        label: Text(
                                          t('quick_farmer_login'),
                                          style: const TextStyle(fontSize: 11),
                                          textAlign: TextAlign.center,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.green.shade800,
                                          side: BorderSide(color: Colors.green.shade800),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          _switchRole(true);
                                          _appState.loginAsFieldOfficer();
                                        },
                                        icon: const Icon(Icons.badge, size: 16),
                                        label: Text(
                                          t('quick_officer_login'),
                                          style: const TextStyle(fontSize: 11),
                                          textAlign: TextAlign.center,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.teal.shade900,
                                          side: BorderSide(color: Colors.teal.shade900),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


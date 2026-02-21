import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/license_service.dart';
import 'home_screen.dart';
import 'activation_screen.dart';
import 'package:ionicons/ionicons.dart';

class SplashLicenseWrapper extends StatelessWidget {
  const SplashLicenseWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LicenseService>(
      builder: (context, license, _) {
        if (license.isInitializing) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blueAccent),
                  SizedBox(height: 16),
                  Text('جاري التحقق من الترخيص...', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            ),
          );
        }

        if (!license.isAuthorized) {
          return const ActivationScreen();
        }

        // We are authorized
        return const HomeScreen(); // Continue to the app
      },
    );
  }
}

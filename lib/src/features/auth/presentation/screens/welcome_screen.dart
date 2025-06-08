import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/common/widgets/primary_button.dart';
import 'package:wink_chat/src/common/widgets/secondary_button.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/login_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/registration_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/footer.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/images_grid.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToRegistration(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegistrationScreen()));
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(width: 200, isDark: false),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          color: Colors.white,
          child: Column(
            children: [
              const Expanded(flex: 2, child: Center(child: ImagesGrid())),
              const SizedBox(height: 30),
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "Witaj w WinkChat",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(1.0),
                      ),
                      const Text(
                        "Łącz sie przez rozmowy, a nie pozory.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(1.0),
                      ),
                      const Text(
                        "Znajdź prawdziwych ludzi w pobliżu i zacznij rozmawiać.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(1.0),
                      ),
                      const SizedBox(height: 50),
                      Expanded(
                        child: Column(
                          spacing: 18,
                          children: [
                            PrimaryButton(
                              onPressed: () => _navigateToRegistration(context),
                              width: double.infinity,
                              child: const Text(
                                "Rozpocznij",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SecondaryButton(
                              onPressed: () => _navigateToLogin(context),
                              width: double.infinity,
                              child: const Text(
                                "Zaloguj się",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(child: Footer()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

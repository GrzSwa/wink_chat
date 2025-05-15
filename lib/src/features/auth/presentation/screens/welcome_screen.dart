import 'package:flutter/material.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/login_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/registration_screen.dart';

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
      appBar: AppBar(title: const Text('WinkChat'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('WinkChat', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _navigateToRegistration(context),
              child: const Text('Zaczynajmy'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _navigateToLogin(context),
              child: const Text('Zaloguj się'),
            ),
          ],
        ),
      ),
    );
  }
}

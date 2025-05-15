import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/main_app_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateToMainApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainAppScreen()),
      (Route<dynamic> route) =>
          false, // This predicate removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ekran Logowania'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () =>
                      _navigateToMainApp(context), // Navigate to MainAppScreen
              child: const Text('Zaloguj (placeholder)'),
            ),
          ],
        ),
      ),
    );
  }
}

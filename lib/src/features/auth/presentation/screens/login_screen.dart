import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/app_images.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/email_input.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/password_input.dart';
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: AppLogo(width: 120),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(222, 103, 108, 1),
      ),
      body: Container(
        color: Color.fromRGBO(222, 103, 108, 1),
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 25),
                child: Column(
                  spacing: 25,
                  children: [
                    AppImages(imagesNumber: 6, width: 200),
                    Text(
                      "Logowanie",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      spacing: 20,
                      children: [EmailInput(), PasswordInput()],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () => {_navigateToMainApp(context)},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: const Text('Zaloguj się'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

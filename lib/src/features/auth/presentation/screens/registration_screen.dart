import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/app_images.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/email_input.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/password_input.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

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
                    Text(
                      "Rejestracja",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    AppImages(imagesNumber: 7, width: 200),
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
                    onPressed: () => {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: const Text('Zarejestruj się'),
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

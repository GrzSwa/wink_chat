import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/common/widgets/field.dart';
import 'package:wink_chat/src/common/widgets/primary_button.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/footer.dart';
import 'package:wink_chat/src/common/widgets/main_app_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/registration_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateToMainApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainAppScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToRegistration(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegistrationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppLogo(width: 120, isDark: false),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    spacing: 20,
                    children: [
                      Text(
                        "Zaloguj się do swojego konta",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(1.0),
                      ),

                      Text(
                        "Kontynuuj swoją przygodę z anonimowym czatem. Wprowadź swój adres e-mail i hasło.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(1.0),
                      ),

                      Field.email(
                        controller: _emailController,
                        placeholder: "Wprowadź adres email",
                      ),
                      Field.password(
                        controller: _passwordController,
                        label: "Hasło",
                        placeholder: "Wprowadź hasło",
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Zapomniałeś hasła?",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      PrimaryButton(
                        onPressed: () => _navigateToMainApp(context),
                        width: double.infinity,
                        child: Text("Zaloguj", style: TextStyle(fontSize: 18)),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Nie masz jeszcze konta?",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _navigateToRegistration(context),
                            child: Text(
                              "Zarejestruj się",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

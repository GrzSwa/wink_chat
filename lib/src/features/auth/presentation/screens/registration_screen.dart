import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/common/widgets/field.dart';
import 'package:wink_chat/src/common/widgets/primary_button.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/footer.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/login_screen.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _nickNameController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppLogo(width: 120, isDark: false),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              spacing: 20,
              children: [
                Text(
                  "Rejestracja",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
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

                Field.input(
                  controller: _nickNameController,
                  label: "Nazwa użytkownika",
                  placeholder: "Wprowadź nazwę użytkownika",
                ),

                Field.radio(
                  options: ["Mężczyzna", "Kobieta", "Inna"],
                  selectedValue: "Mężczyzna",
                  label: "Płeć",
                  onChanged: (value) {},
                ),

                Field.select(
                  options: ["Polska", "Świętokrzyskie", "Podkarpackie"],
                  selectedValue: "Polska",
                  label: "Wybierz swoją lokalizację",
                  onChanged: (onChanged) {},
                ),

                PrimaryButton(
                  onPressed: () {},
                  width: double.infinity,
                  child: Text("Zarejestruj", style: TextStyle(fontSize: 18)),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      "Masz już konto?",
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _navigateToLogin(context),
                      child: Text(
                        "Zaloguj się",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

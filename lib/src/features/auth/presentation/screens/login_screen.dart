import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/common/widgets/field.dart';
import 'package:wink_chat/src/common/widgets/primary_button.dart';
import 'package:wink_chat/src/common/screens/main_app_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/footer.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/registration_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  Future<void> _login() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      final result = await ref
          .read(authFeatureControllerProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!result.hasError) {
        _navigateToMainApp(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFeatureControllerProvider);

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
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    spacing: 20,
                    children: [
                      const Text(
                        "Zaloguj się do swojego konta",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(1.0),
                      ),
                      const Text(
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
                        key: const Key('email_field'),
                        controller: _emailController,
                        placeholder: "Wprowadź adres email",
                      ),
                      Field.password(
                        key: const Key('password_field'),
                        controller: _passwordController,
                        label: "Hasło",
                        placeholder: "Wprowadź hasło",
                      ),
                      const Align(
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
                        onPressed: authState.isLoading ? null : _login,
                        width: double.infinity,
                        child:
                            authState.isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                  "Zaloguj",
                                  style: TextStyle(fontSize: 18),
                                ),
                      ),
                      if (authState.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            authState.error.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
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
                            child: const Text(
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
                  const SizedBox(height: 20),
                  const Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

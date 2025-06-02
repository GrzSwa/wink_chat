import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/common/widgets/field.dart';
import 'package:wink_chat/src/common/widgets/primary_button.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/footer.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/login_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:wink_chat/src/features/auth/data/repositories/firebase_user_repository.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nickNameController = TextEditingController();
  String _selectedGender = "M";
  String _selectedLocationType = "country";
  String _selectedLocationValue = "Polska";
  final _userRepository = FirebaseUserRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nickNameController.dispose();
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _register() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _nickNameController.text.isNotEmpty) {
      final result = await ref
          .read(authControllerProvider.notifier)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!result.hasError) {
        final authUser = ref.read(authStateProvider).value;
        if (authUser != null) {
          await _userRepository.createUserProfile(
            authUser: authUser,
            pseudonim: _nickNameController.text.trim(),
            gender: _selectedGender,
            location: {
              'type': _selectedLocationType,
              'value': _selectedLocationValue,
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null) {
        _navigateToLogin(context);
      }
    });

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
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              spacing: 20,
              children: [
                const Text(
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
                  options: const ["M", "F"],
                  selectedValue: _selectedGender,
                  label: "Płeć",
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGender = value;
                      });
                    }
                  },
                ),
                Field.select(
                  options: const ["Polska", "Świętokrzyskie", "Podkarpackie"],
                  selectedValue: _selectedLocationValue,
                  label: "Wybierz swoją lokalizację",
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLocationValue = value;
                        _selectedLocationType =
                            value == "Polska" ? "country" : "voivodeship";
                      });
                    }
                  },
                ),
                PrimaryButton(
                  onPressed: authState.isLoading ? null : _register,
                  width: double.infinity,
                  child:
                      authState.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                            "Zarejestruj",
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
                      child: const Text(
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
                const Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

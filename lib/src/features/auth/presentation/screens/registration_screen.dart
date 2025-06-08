import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/common/widgets/field.dart';
import 'package:wink_chat/src/common/widgets/primary_button.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/footer.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/login_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:wink_chat/src/features/auth/data/repositories/firebase_user_repository.dart';
import 'package:wink_chat/src/features/auth/presentation/providers/locations_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final FirebaseUserRepository? userRepository;
  final VoidCallback? onRegisterSuccess;

  const RegistrationScreen({
    super.key,
    this.userRepository,
    this.onRegisterSuccess,
  });

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nickNameController = TextEditingController();
  String _selectedGender = "M";
  String? _selectedLocationValue;
  late final FirebaseUserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository ?? FirebaseUserRepository();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nickNameController.dispose();
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) {
    if (widget.onRegisterSuccess != null) {
      widget.onRegisterSuccess!();
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Future<void> _register() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _nickNameController.text.isNotEmpty &&
        _selectedLocationValue != null) {
      final result = await ref
          .read(authFeatureControllerProvider.notifier)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!result.hasError) {
        final authUser = ref.read(authStateProvider).value;
        if (authUser != null) {
          final locationType = await ref.read(
            locationTypeProvider(_selectedLocationValue!).future,
          );
          await _userRepository.createUserProfile(
            authUser: authUser,
            pseudonim: _nickNameController.text.trim(),
            gender: _selectedGender,
            location: {'type': locationType, 'value': _selectedLocationValue!},
          );

          if (!mounted) return;

          _navigateToLogin(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFeatureControllerProvider);
    final locationsAsync = ref.watch(locationsProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null) {
        _navigateToLogin(context);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const AppLogo(width: 120, isDark: false),
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
                Field.input(
                  key: const Key('nickname_field'),
                  controller: _nickNameController,
                  label: "Nazwa użytkownika",
                  placeholder: "Wprowadź nazwę użytkownika",
                ),
                Field.radio(
                  key: const Key('gender_radio_field'),
                  options: const ["M", "F"],
                  selectedValue: _selectedGender,
                  label: "Płeć",
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                locationsAsync.when(
                  data:
                      (locations) => Field.select(
                        key: const Key('location_select_field'),
                        options: locations,
                        selectedValue: _selectedLocationValue,
                        label: "Wybierz swoją lokalizację",
                        onChanged: (value) {
                          setState(() {
                            _selectedLocationValue = value;
                          });
                        },
                      ),
                  loading: () => const CircularProgressIndicator(),
                  error:
                      (_, __) => const Text(
                        "Nie udało się załadować lokalizacji",
                        style: TextStyle(color: Colors.red),
                      ),
                ),
                PrimaryButton(
                  key: const Key('register_button'),
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

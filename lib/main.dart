import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wink_chat/src/common/widgets/main_app_screen.dart';
import 'package:wink_chat/src/common/providers/auth_state_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'WinkChat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(222, 103, 108, 1),
        ),
      ),
      home: authState.when(
        data:
            (user) =>
                user != null ? const MainAppScreen() : const WelcomeScreen(),
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (error, stack) => const WelcomeScreen(),
      ),
    );
  }
}

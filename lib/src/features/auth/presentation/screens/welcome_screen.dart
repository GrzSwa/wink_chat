import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/login_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/screens/registration_screen.dart';
import 'package:wink_chat/src/features/auth/presentation/widgets/images_grid.dart';

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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        color: Color.fromRGBO(222, 103, 108, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [AppLogo(width: 200), ImagesGrid()],
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => _navigateToRegistration(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Text('Zaczynajmy'),
                    ),
                    TextButton(
                      onPressed: () => _navigateToLogin(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Text(
                        'Zaloguj się',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             ImagesGrid(),
//             Container(
//               color: Colors.amberAccent,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 spacing: 10,
//                 children: [
                  // ElevatedButton(
                  //   onPressed: () => _navigateToRegistration(context),
                  //   style: ElevatedButton.styleFrom(
                  //     padding: const EdgeInsets.symmetric(vertical: 15.0),
                  //   ),
                  //   child: const Text('Zaczynajmy'),
                  // ),
                  // TextButton(
                  //   onPressed: () => _navigateToLogin(context),
                  //   style: ElevatedButton.styleFrom(
                  //     padding: const EdgeInsets.symmetric(vertical: 15.0),
                  //   ),
                  //   child: const Text(
                  //     'Zaloguj się',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
//                 ],
//               ),
//             ),
//           ],
//         )

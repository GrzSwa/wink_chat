import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/app_logo.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 5,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              AppLogo(width: 25, isDark: false, isSmall: true),
              Text(
                "Anonimowość. Bezpieczeństwo. Prostota",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          Text(
            "© 2025 WinkChat",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

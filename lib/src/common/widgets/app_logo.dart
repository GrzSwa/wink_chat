import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isDark;
  final bool isSmall;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit,
    this.isDark = true,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      isDark && isSmall
          ? 'assets/logo/msg_bubble_dark.png'
          : !isDark && isSmall
          ? 'assets/logo/msg_bubble_light.png'
          : isDark && !isSmall
          ? 'assets/logo/logo_dark.png'
          : 'assets/logo/logo_light.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

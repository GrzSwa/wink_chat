import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final String logoPath;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const AppLogo({
    Key? key,
    this.logoPath = 'assets/logo/logo_dark.png',
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(logoPath, width: width, height: height, fit: fit);
  }
}

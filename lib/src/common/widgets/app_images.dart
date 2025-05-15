import 'package:flutter/material.dart';

class AppImages extends StatelessWidget {
  static final List<String> imagesList = [
    'assets/images/av_1_color.png',
    'assets/images/av_2_color.png',
    'assets/images/av_3_color.png',
    'assets/images/av_4_color.png',
    'assets/images/av_1.png',
    'assets/images/av_2.png',
    'assets/images/av_3.png',
    'assets/images/av_4.png',
  ];

  final int imagesNumber;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const AppImages({
    Key? key,
    this.imagesNumber = 0,
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagesList[imagesNumber],
      width: width,
      height: height,
      fit: fit,
    );
  }
}

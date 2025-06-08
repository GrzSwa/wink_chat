import 'package:flutter/material.dart';
import 'package:wink_chat/src/common/widgets/app_images.dart';

class ImagesGrid extends StatelessWidget {
  const ImagesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: AppImages(imagesNumber: 2, fit: BoxFit.cover),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: AppImages(imagesNumber: 1, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: AppImages(imagesNumber: 3, fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: AppImages(imagesNumber: 0, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

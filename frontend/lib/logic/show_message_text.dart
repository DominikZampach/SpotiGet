import 'package:flutter/material.dart';
import 'package:web_spotify_downloader/consts.dart';

void showMessageText({
  required String text,
  required BuildContext context,
  required double width,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: Consts.white),
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
      backgroundColor: Consts.secondarySurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(15),
      ),
      width: width,
    ),
  );
}

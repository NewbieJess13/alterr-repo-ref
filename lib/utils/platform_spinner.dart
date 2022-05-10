import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class PlatformSpinner extends StatelessWidget {
  final double height;
  final double width;
  final double strokeWidth;
  final double radius;
  final Color color;
  final Brightness brightness;
  PlatformSpinner(
      {this.height = 10,
      this.width = 10,
      this.strokeWidth = 1.5,
      this.color = Colors.black26,
      this.radius = 10,
      this.brightness = Brightness.light});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Theme(
            data: ThemeData(
                cupertinoOverrideTheme:
                    CupertinoThemeData(brightness: brightness)),
            child: CupertinoActivityIndicator(
              radius: radius,
            ),
          )
        : Center(
            child: SizedBox(
              height: height,
              width: width,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          );
  }
}

import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PlatformBottomsheetModal {
  final Widget child;
  final BuildContext? context;
  final bool? isDismissible;
  final bool? enableDrag;
  final bool? expand;
  const PlatformBottomsheetModal(
      {Key? key,
      required this.child,
      this.isDismissible = true,
      this.enableDrag = true,
      this.expand = false,
      required this.context});

  Future show() async {
    if (Platform.isAndroid) {
      await showMaterialModalBottomSheet(
          useRootNavigator: true,
          isDismissible: isDismissible!,
          expand: expand!,
          enableDrag: enableDrag!,
          barrierColor: Colors.black.withOpacity(0.5),
          duration: Duration(milliseconds: 150),
          context: context!,
          builder: (context) => child);
    } else if (Platform.isIOS) {
      await showCupertinoModalBottomSheet(
          useRootNavigator: true,
          expand: expand!,
          isDismissible: isDismissible,
          enableDrag: enableDrag!,
          barrierColor: Colors.black.withOpacity(0.5),
          duration: Duration(milliseconds: 150),
          elevation: 0,
          context: context!,
          builder: (context) => child);
    }
  }
}

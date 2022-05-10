import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PlatformAlertDialog {
  final String? title;
  final String? content;
  final List<PlatformAlertDialogAction>? actions;
  const PlatformAlertDialog({Key? key, this.title, this.content, this.actions});

  show() {
    Widget? dialog;
    if (Platform.isAndroid) {
      dialog = AlertDialog(
        title: Text(
          title!,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(content!),
        actions: actions,
        contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      );
    } else if (Platform.isIOS) {
      dialog = CupertinoAlertDialog(
        title: Text(title!),
        content: Text(content!),
        actions: actions!,
      );
    }
    showDialog(context: navigator!.context, builder: (_) => dialog!);
  }
}

class PlatformAlertDialogAction extends StatelessWidget {
  final Function()? onPressed;
  final Widget? child;
  final bool? isDefaultAction;
  const PlatformAlertDialogAction(
      {Key? key, this.onPressed, this.child, this.isDefaultAction = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget? dialogAction;
    if (Platform.isAndroid) {
      dialogAction = TextButton(
        child: child!,
        onPressed: onPressed,
      );
    } else if (Platform.isIOS) {
      dialogAction = CupertinoDialogAction(
        child: child!,
        isDefaultAction: isDefaultAction!,
        onPressed: onPressed,
      );
    }
    return dialogAction!;
  }
}

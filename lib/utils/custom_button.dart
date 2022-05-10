import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;
  final String? label;
  final String? theme;
  final bool disabled;
  final bool loading;
  final String size;
  final Widget? prefixIcon;
  final bool pill;
  final bool unconstrained;
  const CustomButton(
      {Key? key,
      required this.onPressed,
      this.color,
      this.label,
      this.disabled = false,
      this.loading = false,
      this.unconstrained = false,
      this.theme = 'primary',
      this.size = 'base',
      this.prefixIcon,
      this.pill = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return unconstrained == true
        ? UnconstrainedBox(
            child: _button(context),
          )
        : SizedBox(
            width: double.infinity,
            child: _button(context),
          );
  }

  Widget _button(BuildContext context) {
    double opacity = disabled || loading ? 0.5 : 1.0;
    double fontSize = 18.0;
    Color borderColor = Colors.transparent;
    double borderWidth = 0.0;
    double borderRadius = 8.0;
    Color backgroundColor = Theme.of(context).primaryColor;
    double height = 45;
    double horizontalPadding = 0;
    if (unconstrained == true) {
      horizontalPadding = 15;
    }
    if (size == 'small') {
      fontSize = 15.0;
      borderRadius = 7.0;
      height = 32;
    } else if (size == 'medium') {
      fontSize = 16.0;
      borderRadius = 7.0;
      height = 38;
    }
    if (theme == 'bordered') {
      borderColor = Colors.black26;
      backgroundColor = Colors.white;
    } else if (theme == 'danger') {
      borderColor = Colors.black26;
      backgroundColor = Colors.red;
    } else if (theme == 'black') {
      borderColor = Colors.black26;
      backgroundColor = Colors.black;
    }

    if (pill == true) {
      borderRadius = 50;
    }
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        color: backgroundColor.withOpacity(opacity),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        onTap: disabled || loading ? null : onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          height: height,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Opacity(
                opacity: loading ? 0 : 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    prefixIcon != null ? prefixIcon! : SizedBox.shrink(),
                    label != null
                        ? Text(
                            label!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 1,
                              color: color != null
                                  ? color
                                  : theme == 'light'
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                              fontSize: fontSize,
                            ),
                          )
                        : SizedBox.shrink()
                  ],
                ),
              ),
              loading ? _indicator() : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator() {
    Widget indicator = Container();
    if (Platform.isAndroid) {
      indicator = SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ));
    } else if (Platform.isIOS) {
      indicator = Positioned.fill(
        child: Theme(
            data: ThemeData(
                cupertinoOverrideTheme:
                    CupertinoThemeData(brightness: Brightness.dark)),
            child: CupertinoActivityIndicator()),
      );
    }
    return indicator;
  }
}

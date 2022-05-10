import 'package:flutter/material.dart';

class CustomAppBar {
  final Widget? leading;
  final String? title;
  final Widget? action;

  CustomAppBar({this.leading, this.title = '', this.action});

  PreferredSizeWidget build() {
    return PreferredSize(
      preferredSize: Size.fromHeight(45),
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 15.0),
        decoration: BoxDecoration(color: Color(0xFFF9F9F9)),
        child: Material(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: leading,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    title!,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: action,
                ),
              ],
            ),
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }
}

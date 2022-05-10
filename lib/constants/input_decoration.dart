import 'package:flutter/material.dart';

class InputDeco {
  InputDeco._();

  static InputDecoration cardFieldDeco = InputDecoration(
      contentPadding: const EdgeInsets.all(10),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
        color: Color(0xFF1860f0),
        width: 2,
      )),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF1860f0),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
        color: Color(0xFF1860f0),
        width: 2,
      )),
      hintStyle: TextStyle(fontSize: 13),
      labelStyle: TextStyle(fontSize: 13, color: Colors.black45));
}

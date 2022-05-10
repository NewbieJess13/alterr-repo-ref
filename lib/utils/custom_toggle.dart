import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomToggleSwitch extends StatelessWidget {
  final ValueChanged<bool> onChanged;
  final bool value;

  const CustomToggleSwitch(
      {Key? key, required this.onChanged, required this.value})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: Theme.of(context).primaryColor,
      value: value,
      onChanged: onChanged,
    );
  }
}

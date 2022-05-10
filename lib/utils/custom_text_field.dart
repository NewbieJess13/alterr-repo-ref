import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final bool? isPassword;
  final bool? readOnly;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final Widget? suffixIcon;
  final VoidCallback? suffixTap;
  final ValueChanged<String>? onChanged;
  final bool? autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? errorMessage;
  final int? maxLength;
  final VoidCallback? onTap;
  final Function()? onEditingComplete;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsets? padding;
  const CustomTextField(
      {Key? key,
      this.title,
      this.icon,
      this.isPassword = false,
      this.controller,
      this.textInputType,
      this.suffixIcon,
      this.suffixTap,
      this.readOnly = false,
      this.autofocus = false,
      this.focusNode,
      this.textInputAction,
      this.onChanged,
      this.errorMessage,
      this.maxLength,
      this.onTap,
      this.onEditingComplete,
      this.maxLines = 1,
      this.padding,
      this.inputFormatters})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              onEditingComplete: onEditingComplete,
              focusNode: focusNode,
              textInputAction: textInputAction,
              autofocus: autofocus!,
              readOnly: readOnly!,
              cursorColor: Colors.black,
              cursorWidth: 1,
              onTap: onTap,
              controller: controller,
              onChanged: onChanged,
              obscureText: isPassword!,
              keyboardType: textInputType,
              maxLines: maxLines,
              style: TextStyle(fontSize: 16),
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              decoration: InputDecoration(
                counterText: "",
                errorText: errorMessage,
                isCollapsed: true,
                contentPadding: const EdgeInsets.all(15.0),
                hintText: title,
                hintStyle: TextStyle(fontSize: 16, color: Colors.black26),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                )),
              ),
            ),
          ),
          suffixIcon != null
              ? Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(onTap: suffixTap, child: suffixIcon),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }
}

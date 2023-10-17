import 'package:flutter/material.dart';

class TextFieldHelper<T> extends StatefulWidget {
  String? label;
  String? hint;
  String? value;
  Color backgroundColor;
  double fontSize;
  FontWeight fontWeight;
  TextInputType? inputType;
  TextInputAction? inputAction;
  bool autoFocus;
  IconData? prefixIcon;
  int? maxLength;
  bool showCursor;
  bool isformField;
  Widget? suffix;
  double contentPadding;
  bool multiLine;
  bool obscureText;
  TextEditingController? controller;
  String? Function(String?)? validator;
  Function(String)? onchanged;
  Function(String?)? onSaved;

  TextFieldHelper(
      {super.key,
      this.label,
      this.hint,
      this.value,
      this.backgroundColor = Colors.grey,
      this.fontSize = 18,
      this.fontWeight = FontWeight.normal,
      this.maxLength,
      this.autoFocus = false,
      this.inputType,
      this.inputAction,
      this.prefixIcon,
      this.isformField = false,
      this.validator,
      this.showCursor = true,
      this.multiLine = false,
      this.onchanged,
      this.contentPadding = 20,
      this.obscureText = false,
      this.suffix,
      this.controller,
      this.onSaved});

  @override
  State<TextFieldHelper<T>> createState() => _CustomTextFieldState<T>();
}

class _CustomTextFieldState<T> extends State<TextFieldHelper<T>> {
  final FocusNode _focus = FocusNode();
  bool? isFocused = null;
  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
            autofocus: widget.autoFocus,
            controller: widget.controller,
            validator: (v) {
              if(isFocused == true){
                return widget.validator?.call(v);

              }
            },
            onChanged: (newValue) {
              widget.onchanged?.call(newValue);
            },
            onSaved: (value) {
              widget.onSaved?.call(value);
            },
            obscureText: widget.obscureText,
            focusNode: _focus,
            initialValue: widget.value,
            keyboardType: widget.inputType,
            textInputAction: widget.inputAction,
            style: TextStyle(
                fontSize: widget.fontSize, fontWeight: widget.fontWeight, color: Colors.black),
            maxLength: widget.maxLength,
            showCursor: widget.showCursor,
            decoration: InputDecoration(
                suffix: widget.suffix,
                filled: false,
                label: Text(widget.label ?? ""),
                hintText: widget.label != null ? "Enter ${widget.label}" : null,
                prefixIcon:
                    widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
                contentPadding: EdgeInsets.all(widget.contentPadding)),
          );
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isFocused = _focus.hasFocus;
    });
  }
}

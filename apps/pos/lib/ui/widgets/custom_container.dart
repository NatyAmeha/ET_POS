import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  Widget child;
  Color? color;
  double? width;
  double? height;
  EdgeInsets? customPadding;
  EdgeInsets? customMargin;
  double? padding;
  double? margin;
  double borderRadius;
  List<double>? selectedBorderSidesForRadius;
  Color? borderColor;
  List<Color>? gradientColor;
  AlignmentGeometry? alignment;
  bool addshadow;
  Function? onTap;
  CustomContainer(
      {super.key,
      required this.child,
      this.color,
      this.width = double.infinity,
      this.height,
      this.customPadding,
      this.customMargin,
      this.padding,
      this.margin,
      this.borderRadius = 0,
      this.selectedBorderSidesForRadius,
      this.addshadow = false,
      this.borderColor = Colors.transparent,
      this.gradientColor,
      this.alignment,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap != null
          ? () {
              onTap?.call();
            }
          : null,
      child: Container(
        width: width,
        height: height,
        alignment: alignment ?? AlignmentDirectional.center,
        padding: customPadding ?? EdgeInsets.all(padding ?? 16),
        margin: customMargin ?? EdgeInsets.all(margin ?? 0),
        decoration: BoxDecoration(
            borderRadius: selectedBorderSidesForRadius == null 
              ? BorderRadius.circular(borderRadius)
              : BorderRadiusDirectional.only(
                  topStart: Radius.circular(selectedBorderSidesForRadius?.elementAtOrNull(0) ?? 0),
                  topEnd: Radius.circular(selectedBorderSidesForRadius?.elementAtOrNull(1) ?? 0),
                  bottomEnd: Radius.circular(selectedBorderSidesForRadius?.elementAtOrNull(2) ?? 0),
                  bottomStart: Radius.circular(selectedBorderSidesForRadius?.elementAtOrNull(3) ?? 0),
                ),
            border: Border.all(color: borderColor ?? Colors.white),
            color: color,
            boxShadow: addshadow ? [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0, // soften the shadow
                offset: Offset(0.0, 5.0),
              )
            ] : null,
            gradient: gradientColor?.isNotEmpty == true
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradientColor!)
                : null),
        child: child,
      ),
    );
  }
}

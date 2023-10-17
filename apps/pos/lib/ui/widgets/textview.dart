import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  String? text;
  double margin = 0,
      startMargin = 0,
      endMargin = 0,
      topMargin = 0,
      bottomMargin = 0;
  TextStyle? textStyle;
  TextAlign textAlignment;
  double textSize = 14;
  double padding = 0,
      startPadding = 0,
      endPadding = 0,
      topPadding = 0,
      bottomPadding = 0;
  Color? textColor, backgroundColor;
  bool? setBold;
  Alignment? alignment;
  int maxline =1;
  VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      alignment: alignment,
      margin: margin == 0
          ? EdgeInsets.fromLTRB(startMargin, topMargin, endMargin, bottomMargin)
          : EdgeInsets.all(margin),
      padding: padding == null
          ? EdgeInsets.fromLTRB(
              startPadding, topPadding, endPadding, bottomPadding)
          : EdgeInsets.all(padding),
      child: Text(
        text!,
        overflow: TextOverflow.ellipsis,
        maxLines: maxline,
        textAlign: textAlignment,
        style: textStyle != null
            ? textStyle!.copyWith(color: textColor, fontWeight: setBold != null ? (setBold == true ? FontWeight.bold : FontWeight.normal )  : textStyle?.fontWeight)
            : TextStyle(
                color:
                    textColor != null ? textColor : Colors.black,
                fontWeight: setBold == true ?  FontWeight.bold : FontWeight.normal,
                fontSize: textSize),
      ),

    );
  }

  TextView(String? this.text,
      {Key? key,
      this.margin = 0,
      this.startMargin = 0,
      this.endMargin = 0,
      this.topMargin = 0,
      this.bottomMargin = 0,
      this.textStyle,
      this.padding = 0,
      this.startPadding = 0,
      this.endPadding = 0,
      this.topPadding = 0,
      this.bottomPadding = 0,
      this.textColor,
      this.backgroundColor,
      this.setBold,
      this.textSize = 14,
      this.alignment,
      this.maxline=1,
      this.textAlignment = TextAlign.start
      });
}

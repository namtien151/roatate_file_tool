import 'package:flutter/material.dart';
import 'package:roatate_file_tool/ui/common/app_colors.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

double titleText = 24.0;
double normalText = 16.0;
double smallText = 10.0;

TextStyle titleTextStyle = TextStyle(
  fontSize: titleText,
);
TextStyle normalTextStyle = TextStyle(
  fontSize: normalText,
);
TextStyle smallTextStyle = TextStyle(
  fontSize: smallText,
);

// ignore: must_be_immutable
class ClassText extends StatelessWidget {
  String text;
  TextStyle textStyle;
  Color? colorText;
  FontWeight? fontWeight;
  double? letterSpacing;
  String? fontFamily;
  FontStyle? fontStyle;
  double? fontSize;
  bool? textShowFull = true;
  TextAlign? textAlign;
  int? maxLines;
  TextDecoration? decoration;
  Color? backgroundColor;
  ClassText.title({
    super.key,
    required this.text,
    this.colorText = Colors.black,
    this.fontWeight = FontWeight.w700,
    // this.fontFamily = FontFamily.montserrat,
    this.letterSpacing,
    this.fontStyle,
    this.fontSize,
  }) : textStyle = titleTextStyle.copyWith(
          fontSize: fontSize,
          color: colorText,
          fontWeight: fontWeight,
          // fontFamily: fontFamily,
          letterSpacing: letterSpacing,
          fontStyle: fontStyle,
        );
  ClassText.normal(
      {super.key,
      required this.text,
      this.colorText = kcTextIconColor,
      this.fontWeight = FontWeight.w400,
      this.fontSize,
      this.fontFamily,
      this.textShowFull,
      this.maxLines,
      this.backgroundColor,
      this.decoration,
      this.textAlign,
      this.letterSpacing})
      : textStyle = normalTextStyle.copyWith(
            fontSize: fontSize,
            color: colorText,
            fontFamily: fontFamily,
            decoration: decoration,
            decorationColor: colorText,
            backgroundColor: backgroundColor,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing);
  ClassText.small({
    super.key,
    required this.text,
    this.colorText = Colors.black,
    this.fontWeight,
    this.fontFamily,
  }) : textStyle = smallTextStyle.copyWith(
          color: colorText,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
        );

  @override
  Widget build(BuildContext context) {
    return textShowFull ?? true
        ? Text(
            text,
            style: textStyle,
            textAlign: textAlign ?? TextAlign.start,
          )
        : Text(
            text,
            style: textStyle,
            maxLines: maxLines ?? 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign ?? TextAlign.start,
          );
  }
}

// ignore: must_be_immutable
class GradientText extends StatelessWidget {
  GradientText({
    super.key,
    required this.child,
    required this.gradient,
    this.style,
  });

  Widget? child;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: child,
    );
  }
}

// ignore: must_be_immutable
class RichTextMessWidget extends StatelessWidget {
  String? textOne;
  String? textTwo;
  String? textThree;
  TextStyle? styleOne;
  TextStyle? styleTwo;
  TextStyle? styleThree;
  TextAlign? textAlign;
  RichTextMessWidget({
    Key? key,
    this.textOne,
    this.textTwo,
    this.textThree,
    this.styleOne,
    this.styleTwo,
    this.styleThree,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        textAlign: textAlign ?? TextAlign.start,
        text: TextSpan(children: [
          TextSpan(text: textOne, style: styleOne),
          TextSpan(text: textTwo, style: styleTwo),
          TextSpan(text: textThree, style: styleThree ?? styleOne),
        ]));
  }
}

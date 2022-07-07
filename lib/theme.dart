import 'package:flutter/material.dart';

final ThemeData NetenTheme = ThemeData(
    textTheme: _mainTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        onSurface: Colors.white,
        primary: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData().copyWith(
      thickness: MaterialStateProperty.all(15),
      radius: Radius.circular(50),
      thumbColor: MaterialStateProperty.all(NetenColor.scrollBarColor),
    ));

class NetenColor extends Color {
  NetenColor(int value) : super(value);
  static const Color primaryColor = Color(0xFF0EB53B);
  static const Color secondaryColor = Color(0xFF289D47);
  static const Color whiteText = Color(0xFFF0F0F0);
  static const Color backgroundColor = Color(0xFFE5E5E5);
  static const Color blackText = Color(0xFF141414);
  static const Color greyText = Color(0xFF605050);
  static const Color iconColor = Color(0xFF464D5C);
  static const Color buttonColor = Color(0xFF27B24C);
  static const Color greyBorder = Color(0xFF464D5C);
  static const Color lightGreyBorder = Color(0xFFCBCBCB);
  static const Color scrollBarColor = Color(0xFF787C8B);
}

TextTheme _mainTextTheme = const TextTheme(
  headline1: TextStyle(
      fontSize: 56,
      letterSpacing: 0.5,
      height: 1.5,
      fontWeight: FontWeight.bold,
      fontFamily: 'DaysOne',
      color: NetenColor.whiteText
      //color: RendinColor.highEmphasisHeadlineTextColor
      ),
  headline2: TextStyle(
      fontSize: 44,
      letterSpacing: 0,
      height: 1.5,
      fontFamily: 'DaysOne',
      fontWeight: FontWeight.bold,
      color: NetenColor.primaryColor),
  headline3: TextStyle(
      fontSize: 24,
      letterSpacing: 0,
      height: 1.5,
      fontFamily: 'DaysOne',
      fontWeight: FontWeight.w500,
      color: NetenColor.primaryColor),
  headline4:
      TextStyle(fontSize: 20, letterSpacing: 0.15, height: 1.5, fontFamily: 'Inter', fontWeight: FontWeight.w500),
  headline5: TextStyle(
    fontSize: 20,
    letterSpacing: 0.25,
    height: 1.5,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    //color: RendinColor.highEmphasisHeadlineTextColor
  ),
  headline6: TextStyle(
      //color: RendinColor.highEmphasisHeadlineTextColor,
      fontWeight: FontWeight.w500,
      fontSize: 18,
      letterSpacing: 0.25,
      height: 1.5),
  subtitle1:
      TextStyle(fontSize: 16, letterSpacing: 0.25, height: 1.2, fontFamily: 'Inter', fontWeight: FontWeight.normal),
  bodyText1: TextStyle(
      fontSize: 27,
      letterSpacing: 0.25,
      height: 1.5,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      color: NetenColor.blackText),
  bodyText2: TextStyle(
      fontSize: 17,
      letterSpacing: 0.15,
      height: 1.5,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      color: NetenColor.greyText),
  button: TextStyle(
    fontSize: 14,
    letterSpacing: 0.15,
    height: 1.5,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  ),
  caption: TextStyle(
    fontSize: 12,
    letterSpacing: 0.4,
    height: 1.2,
    fontFamily: 'Inter',
    fontWeight: FontWeight.normal,
  ),
  overline: TextStyle(
    fontSize: 12,
    letterSpacing: 2,
    height: 1.5,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  ),
);

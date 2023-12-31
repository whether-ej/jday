import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor whiteP = MaterialColor(
    0xffffffff,
    <int, Color>{
      50: Color(0xffe6e6e6),
      100: Color(0xffcccccc),
      200: Color(0xffb3b3b3),
      300: Color(0xff999999),
      400: Color(0xff808080),
      500: Color(0xff666666),
      600: Color(0xff4c4c4c),
      700: Color(0xff333333),
      800: Color(0xff191919),
      900: Color(0xff000000),
    },
  );

  static const MaterialColor blackP = MaterialColor(
    0xff4c4c4c,
    // 0xffffffff,
    <int, Color>{
      50: Color(0xffffffff),
      100: Color(0xffe6e6e6),
      200: Color(0xffcccccc),
      300: Color(0xffb3b3b3),
      400: Color(0xff999999),
      500: Color(0xff808080),
      600: Color(0xff666666),
      700: Color(0xff4c4c4c),
      800: Color(0xff333333),
      900: Color(0xff191919),
    },
  );
}

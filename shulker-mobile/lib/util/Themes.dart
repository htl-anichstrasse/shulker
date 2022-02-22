import 'package:flutter/material.dart';


MaterialColor PrimaryMaterialColor = MaterialColor(
  4282603437,
  <int, Color>{
    50: Color.fromRGBO(
      67,
      87,
      173,
      .1,
    ),
    100: Color.fromRGBO(
      67,
      87,
      173,
      .2,
    ),
    200: Color.fromRGBO(
      67,
      87,
      173,
      .3,
    ),
    300: Color.fromRGBO(
      67,
      87,
      173,
      .4,
    ),
    400: Color.fromRGBO(
      67,
      87,
      173,
      .5,
    ),
    500: Color.fromRGBO(
      67,
      87,
      173,
      .6,
    ),
    600: Color.fromRGBO(
      67,
      87,
      173,
      .7,
    ),
    700: Color.fromRGBO(
      67,
      87,
      173,
      .8,
    ),
    800: Color.fromRGBO(
      67,
      87,
      173,
      .9,
    ),
    900: Color.fromRGBO(
      67,
      87,
      173,
      1,
    ),
  },
);

ThemeData myTheme = ThemeData(
  fontFamily: "customFont",
  primaryColor: Color(0xff4357ad),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        Color(0xff4357ad),
      ),
    ),
  ), colorScheme: ColorScheme.fromSwatch(primarySwatch: PrimaryMaterialColor).copyWith(secondary: Color(0xff4357ad)),
);
  
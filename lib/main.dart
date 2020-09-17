import 'package:flutter/material.dart';
import 'package:zaza/constants.dart';
import 'package:zaza/screens/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primaryColor = ZazaColors.brownBread;
    final primaryColorLight = ZazaColors.whiteChocolate;
    final primaryColorDark = ZazaColors.chocolate;
    final accentColor = ZazaColors.strawberryPink;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: primaryColor,
          primaryColorLight: primaryColorLight,
          primaryColorDark: primaryColorDark,
          accentColor: accentColor,
          textTheme: TextTheme(
              subtitle2: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColorLight,
                  fontSize: 18))),
      home: HomePage(),
    );
  }
}

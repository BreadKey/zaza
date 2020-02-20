import 'package:flutter/material.dart';
import 'package:zaza/screens/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFFD9B484);
    final primaryColorLight = Color(0xFFF5F5DC);
    final primaryColorDark = Color(0xFF312123);
    final accentColor = Color(0xFFFF9191);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: primaryColor,
          primaryColorLight: primaryColorLight,
          primaryColorDark: primaryColorDark,
          accentColor: accentColor,
          textTheme: TextTheme(
              subtitle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColorLight,
                  fontSize: 18))),
      home: HomePage(),
    );
  }
}

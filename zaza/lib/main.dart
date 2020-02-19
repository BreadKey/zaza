import 'package:flutter/material.dart';
import 'package:zaza/screens/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFFD9B484),
          primaryColorLight: Color(0xFFF5F5DC),
          primaryColorDark: Color(0xFF312123),
          accentColor: Color(0xFFFF9191)),
      home: HomePage(),
    );
  }
}

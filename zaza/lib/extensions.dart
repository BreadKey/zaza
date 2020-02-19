import 'package:flutter/material.dart';

extension YearMonthIndexConverter on DateTime {
  static const _startYear = 2000;

  int get toYearMonthIndex => (this.year - _startYear) * 12 + this.month;

  static DateTime fromYearMonthIndex(int index) =>
      DateTime(_startYear + index ~/ 12, index % 12);
}

extension DayTextStyle on ThemeData {
  TextStyle get saturdayTextStyle =>
      TextStyle(
          fontWeight: FontWeight.w600, color: primaryColorDark);
  TextStyle get sundayTextStyle => TextStyle(fontWeight: FontWeight.w600, color: accentColor);
}
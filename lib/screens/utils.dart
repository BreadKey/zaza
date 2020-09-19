import 'package:flutter/material.dart';
import 'package:zaza/constants.dart';
import 'package:zaza/models/week_day.dart';

Color getScoreColor(num conditionScore) {
  return conditionScore == null
      ? Colors.transparent
      : conditionScore > 90
          ? ZazaColors.greenary
          : conditionScore > 70
              ? ZazaColors.lime
              : conditionScore > 50
                  ? ZazaColors.samoanSun
                  : conditionScore > 25
                      ? ZazaColors.sunOrange
                      : Colors.redAccent;
}

Color getWeekDayColor(WeekDay weekDay) {
  switch (weekDay) {
      case WeekDay.sunday:
        return ZazaColors.strawberryPink;
      case WeekDay.saturday:
        return ZazaColors.chocolate;
      default:
        return Colors.black87;
    }
}

extension DayTextStyle on ThemeData {
  TextStyle get saturdayTextStyle =>
      TextStyle(fontWeight: FontWeight.w600, color: primaryColorDark);
  TextStyle get sundayTextStyle =>
      TextStyle(fontWeight: FontWeight.w600, color: accentColor);
}
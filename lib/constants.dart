import 'package:flutter/material.dart';
import 'package:zaza/models/week_day.dart';

class Strings {
  Strings._();

  static const zaza = "Zaza";
  static const editSleepRecordTitle = "기록하기";
  static const sleepTime = "수면 시간";
  static const condition = "컨디션";
  static const pleaseEnterOnlyNumber = "숫자만 입력해 주세요!";
  static const pleaseEnterCorrectScore = "0~100 사이의 숫자를 입력해 주세요!";
  static const hourSuffix = "시간";
  static const scoreSuffix = "점";
  static const sleepRecordChartTitle = "시간별 점수 그래프";

  static String buildWeekDay(WeekDay weekDay) {
    switch (weekDay) {
      case WeekDay.monday:
        return "월";
      case WeekDay.tuesday:
        return "화";
      case WeekDay.wednesday:
        return "수";
      case WeekDay.thursday:
        return "목";
      case WeekDay.friday:
        return "금";
      case WeekDay.saturday:
        return "토";
      case WeekDay.sunday:
        return "일";

      default:
        return null;
    }
  }
}

/// Colors are from pantone
class ZazaColors {
  ZazaColors._();

  static const bread = Color(0xFFFAD692);
  static const brownBread = Color(0xFFC68958);
  static const chocolate = Color(0xFF503130);
  static const whiteChocolate = Color(0xFFEDE6D6);
  static const strawberryPink = Color(0xFFF88192);
  static const samoanSun = Color(0xFFFBC85F);
  static const sunOrange = Color(0xFFF48048);
  static const lime = Color(0xFFA9C23F);
  static const greenary = Color(0xFF00A651);
}

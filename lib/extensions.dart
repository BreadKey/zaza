extension YearMonthIndexConverter on DateTime {
  static const _startYear = 2000;

  int get toYearMonthIndex => (this.year - _startYear) * 12 + this.month;

  static DateTime fromYearMonthIndex(int index) =>
      DateTime(_startYear + index ~/ 12, index % 12);
}
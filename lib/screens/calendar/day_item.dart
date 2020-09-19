part of 'package:zaza/screens/calendar.dart';

class DayItem extends StatelessWidget {
  final int day;
  final WeekDay weekDay;
  final Function onTap;
  final bool isToday;
  final SleepRecord sleepRecord;

  const DayItem(
      {Key key,
      @required this.day,
      @required this.weekDay,
      this.onTap,
      this.isToday: false,
      this.sleepRecord})
      : assert(day != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = _getDayTextColor(context);

    final hourText = sleepRecord == null ? "" : "${sleepRecord.sleepHours}h";

    return Container(
        margin: EdgeInsets.all(1),
        child: Material(
            shape: CircleBorder(),
            color: getScoreColor(sleepRecord?.conditionScore),
            child: Container(
                margin: EdgeInsets.all(3),
                child: Stack(
                  children: <Widget>[
                    SizedBox.expand(
                      child: FlatButton(
                        color: isToday
                            ? Theme.of(context).accentColor
                            : Colors.transparent,
                        shape: CircleBorder(),
                        textColor: textColor,
                        disabledTextColor: textColor.withOpacity(0.5),
                        onPressed: onTap,
                        child: Text("$day"),
                      ),
                    ),
                    Positioned.fill(
                        left: 2,
                        top: 2,
                        child: Stack(
                          children: <Widget>[
                            Text(
                              hourText,
                              style: TextStyle(
                                fontSize: 10,
                                foreground: Paint()
                                  ..color = Theme.of(context).primaryColorDark
                                  ..strokeWidth = 2
                                  ..style = PaintingStyle.stroke,
                              ),
                            ),
                            Text(
                              hourText,
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white),
                            )
                          ],
                        ))
                  ],
                ))));
  }

  Color _getDayTextColor(BuildContext context) {
    if (isToday) return Colors.white;

    return getWeekDayColor(weekDay);
  }
}

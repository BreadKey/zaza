import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zaza/blocs/sleep_record_bloc.dart';
import 'package:zaza/extensions.dart';
import 'package:zaza/constants.dart';
import 'package:zaza/models/sleep_record.dart';

part 'edit_sleep_record_dialog.dart';

part 'sleep_record_chart.dart';

Color getDayColor(num conditionScore) {
  return conditionScore == null
      ? Colors.transparent
      : conditionScore > 90
          ? Colors.green
          : conditionScore > 70
              ? Colors.lime
              : conditionScore > 50
                  ? Colors.yellow
                  : conditionScore > 25
                      ? Colors.orangeAccent
                      : Colors.redAccent;
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final _today = DateTime.now();
  PageController _pageController;

  final _sleepRecordBloc = SleepRecordBloc();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _today.toYearMonthIndex);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _sleepRecordBloc.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: _CalendarHeader(
              controller: _pageController,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: themeData.primaryColorLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(Strings.monday),
                  Text(Strings.tuesday),
                  Text(Strings.wednesday),
                  Text(Strings.thursday),
                  Text(Strings.friday),
                  Text(Strings.saturday, style: themeData.saturdayTextStyle),
                  Text(Strings.sunday, style: themeData.sundayTextStyle),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: themeData.scaffoldBackgroundColor,
                    expandedHeight:
                        MediaQuery.of(context).size.width * 6 / 7 / 0.9,
                    flexibleSpace: FlexibleSpaceBar(
                      background: PageView.builder(
                        itemBuilder: (context, index) => _Calendar(
                          _sleepRecordBloc,
                          index,
                          key: Key("calendar$index"),
                        ),
                        controller: _pageController,
                      ),
                    ),
                  ),
                  SliverGrid.count(
                    crossAxisCount: 1,
                    children: <Widget>[
                      Container(
                        color: themeData.primaryColorDark,
                        child: _SleepRecordChart(_sleepRecordBloc),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class _CalendarHeader extends StatefulWidget {
  final PageController _controller;

  const _CalendarHeader({Key key, @required PageController controller})
      : assert(controller != null),
        _controller = controller,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarHeaderState(_controller);
}

class _CalendarHeaderState extends State<_CalendarHeader> {
  final PageController _controller;
  DateTime _currentDate;

  _CalendarHeaderState(this._controller);

  Function() _controllerListener;

  @override
  void initState() {
    super.initState();
    _currentDate =
        YearMonthIndexConverter.fromYearMonthIndex(_controller.initialPage);
    _controllerListener = () {
      setState(() {
        _currentDate = YearMonthIndexConverter.fromYearMonthIndex(
            _controller.page.round());
      });
    };
    _controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = _currentDate.toYearMonthIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              _controller.animateToPage(--currentIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            }),
        Text(
          "${_currentDate?.year}.${_currentDate?.month}",
          style: Theme.of(context).textTheme.subtitle,
        ),
        IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              _controller.animateToPage(++currentIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            }),
      ],
    );
  }
}

class _Calendar extends StatefulWidget {
  final SleepRecordBloc _sleepRecordBloc;
  final int monthIndex;

  const _Calendar(this._sleepRecordBloc, this.monthIndex, {key: Key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _CalendarState(_sleepRecordBloc, monthIndex);
}

class _CalendarState extends State<_Calendar>
    with AutomaticKeepAliveClientMixin {
  final SleepRecordBloc _sleepRecordBloc;
  final int _monthIndex;
  List<SleepRecord> _sleepRecords = [];
  DateTime _today = DateTime.now();
  ThemeData _themeData;
  RefreshController _refreshController;

  _CalendarState(this._sleepRecordBloc, this._monthIndex);

  StreamSubscription _editedSleepRecordListener;
  StreamSubscription _removedSleepRecordListener;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
    _editedSleepRecordListener =
        _sleepRecordBloc.editedSleepRecord.listen((editedSleepRecord) {
      _onSleepRecordEdited(editedSleepRecord);
    });

    _removedSleepRecordListener =
        _sleepRecordBloc.removedSleepRecord.listen((removedSleepRecord) {
      _onSleepRecordRemoved(removedSleepRecord);
    });
  }

  @override
  void dispose() {
    _editedSleepRecordListener.cancel();
    _removedSleepRecordListener.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  void refresh() {
    _sleepRecordBloc.findByMonthIndex(_monthIndex).then((sleepRecords) {
      setState(() {
        _sleepRecords = sleepRecords;
        _today = DateTime.now();
        _refreshController.refreshCompleted();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);

    final dateFromIndex =
        YearMonthIndexConverter.fromYearMonthIndex(_monthIndex);

    final weekDay = dateFromIndex.weekday - 2;
    final endDay = DateTime(dateFromIndex.year, dateFromIndex.month + 1, 0).day;

    return SmartRefresher(
      header: WaterDropMaterialHeader(
        backgroundColor: _themeData.primaryColorLight,
        color: _themeData.accentColor,
      ),
      controller: _refreshController,
      onRefresh: refresh,
      child: GridView.count(
        crossAxisCount: 7,
        childAspectRatio: 0.9,
        children: List.generate(42, (index) {
          final day = index - weekDay;
          final currentDay =
              DateTime(dateFromIndex.year, dateFromIndex.month, day);
          final isToday = _isToday(currentDay);

          final sleepRecord = _sleepRecords
              .firstWhere((record) => record.day == day, orElse: () => null);

          final textColor = _getDayTextColor(day, index % 7 + 1, isToday);

          final hourText =
              sleepRecord == null ? "" : "${sleepRecord.sleepHours}h";

          return Container(
              margin: EdgeInsets.all(1),
              child: Material(
                  shape: CircleBorder(),
                  color: getDayColor(sleepRecord?.conditionScore),
                  child: Container(
                      margin: EdgeInsets.all(3),
                      child: Stack(
                        children: <Widget>[
                          SizedBox.expand(
                            child: FlatButton(
                              color: isToday
                                  ? _themeData.accentColor
                                  : Colors.transparent,
                              shape: CircleBorder(),
                              textColor: textColor,
                              disabledTextColor: textColor.withOpacity(0.5),
                              onPressed: day > 0 && day < endDay
                                  ? _today.isBefore(currentDay)
                                      ? null
                                      : () {
                                          _showEditSleepRecordDialog(
                                              context, sleepRecord, day);
                                        }
                                  : null,
                              child:
                                  day > 0 && day < endDay ? Text("$day") : null,
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
                                        ..color = _themeData.primaryColorDark
                                        ..strokeWidth = 2
                                        ..style = PaintingStyle.stroke,
                                    ),
                                  ),
                                  Text(
                                    hourText,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  )
                                ],
                              ))
                        ],
                      ))));
        }),
      ),
    );
  }

  void _showEditSleepRecordDialog(
      BuildContext context, SleepRecord sleepRecord, int day) {
    showDialog(
        context: context,
        builder: (context) => _EditSleepRecordDialog(
            _sleepRecordBloc, sleepRecord, _monthIndex, day));
  }

  Color _getDayTextColor(int day, int weekDay, bool isToday) {
    if (isToday) return Colors.white;

    switch (weekDay) {
      case 7:
        return _themeData.accentColor;
      case 6:
        return _themeData.primaryColorDark;
      default:
        return _themeData.textTheme.body1.color;
    }
  }

  bool _isToday(DateTime date) =>
      _today.year == date.year &&
      _today.month == date.month &&
      _today.day == date.day;

  void _onSleepRecordEdited(SleepRecord sleepRecord) {
    if (sleepRecord.monthIndex != _monthIndex) return;

    setState(() {
      _sleepRecords.removeWhere((record) =>
          record.monthIndex == sleepRecord.monthIndex &&
          record.day == sleepRecord.day);
      _sleepRecords.add(sleepRecord);
    });
  }

  void _onSleepRecordRemoved(SleepRecord sleepRecord) {
    setState(() {
      _sleepRecords.remove(sleepRecord);
    });
  }

  @override
  bool get wantKeepAlive => true;
}

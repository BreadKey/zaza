import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zaza/blocs/sleep_record_bloc.dart';
import 'package:zaza/constants.dart';
import 'package:zaza/extensions.dart';
import 'package:zaza/models/sleep_record.dart';
import 'package:zaza/models/week_day.dart';
import 'package:zaza/screens/edit_sleep_record_dialog.dart';
import 'package:zaza/screens/utils.dart';

part 'package:zaza/screens/calendar/day_item.dart';
part 'package:zaza/screens/calendar/month_mover.dart';

class Calendar extends StatefulWidget {
  final int monthIndex;

  const Calendar(this.monthIndex, {key: Key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with AutomaticKeepAliveClientMixin {
  final _sleepRecordsCache = <int, SleepRecord>{};
  DateTime _today = DateTime.now();
  ThemeData _themeData;
  RefreshController _refreshController;

  CompositeSubscription _disposables;

  SleepRecordBloc _sleepRecordBloc;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
    _sleepRecordBloc = context.read<SleepRecordBloc>();
    _disposables = CompositeSubscription();
    _disposables
        .add(_sleepRecordBloc.editedSleepRecord.listen((editedSleepRecord) {
      _onSleepRecordEdited(editedSleepRecord);
    }));

    _disposables
        .add(_sleepRecordBloc.removedSleepRecord.listen((removedSleepRecord) {
      _onSleepRecordRemoved(removedSleepRecord);
    }));
  }

  @override
  void dispose() {
    _disposables.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void refresh() async {
    final sleepRecords =
        await _sleepRecordBloc.findByMonthIndex(widget.monthIndex);

    sleepRecords.forEach((sleepRecord) {
      _sleepRecordsCache[sleepRecord.day] = sleepRecord;
    });

    setState(() {
      _today = DateTime.now();
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _themeData = Theme.of(context);

    final dateFromIndex =
        YearMonthIndexConverter.fromYearMonthIndex(widget.monthIndex);

    final startDay = dateFromIndex.weekday - 2;
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
        children: List.generate(42, (index) {
          final day = index - startDay;
          final currentDay =
              DateTime(dateFromIndex.year, dateFromIndex.month, day);
          final isToday = _isToday(currentDay);

          final sleepRecord = _sleepRecordsCache[day];

          final isValidDay = day > 0 && day <= endDay;

          return isValidDay
              ? DayItem(
                  day: day,
                  key: ValueKey(day),
                  weekDay: WeekDay.values[index % 7],
                  onTap: currentDay.isBefore(_today)
                      ? () {
                          _showEditSleepRecordDialog(context, sleepRecord, day);
                        }
                      : null,
                  isToday: isToday,
                  sleepRecord: sleepRecord,
                )
              : Container();
        }),
      ),
    );
  }

  void _showEditSleepRecordDialog(
      BuildContext context, SleepRecord sleepRecord, int day) {
    showDialog(
        context: context,
        builder: (context) => EditSleepRecordDialog(
            _sleepRecordBloc, sleepRecord, widget.monthIndex, day));
  }

  bool _isToday(DateTime date) =>
      _today.year == date.year &&
      _today.month == date.month &&
      _today.day == date.day;

  void _onSleepRecordEdited(SleepRecord sleepRecord) {
    if (sleepRecord.monthIndex != widget.monthIndex) return;

    setState(() {
      _sleepRecordsCache[sleepRecord.day] = sleepRecord;
    });
  }

  void _onSleepRecordRemoved(SleepRecord sleepRecord) {
    setState(() {
      _sleepRecordsCache.remove(sleepRecord.day);
    });
  }

  @override
  bool get wantKeepAlive => true;
}

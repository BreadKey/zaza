import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zaza/blocs/sleep_record_bloc.dart';
import 'package:zaza/constants.dart';
import 'package:zaza/extensions.dart';
import 'package:zaza/models/week_day.dart';

import 'calendar.dart';
import 'sleep_record_chart.dart';
import 'utils.dart';

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(Strings.zaza),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Column(
              children: [
                MonthMover(
                  controller: _pageController,
                ),
                Container(
                  color: themeData.primaryColorLight,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: WeekDay.values
                        .map((weekDay) => Text(
                              Strings.buildWeekDay(weekDay),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color: getWeekDayColor(weekDay)),
                            ))
                        .toList(),
                  ),
                )
              ],
            )),
      ),
      body: Provider.value(
        value: _sleepRecordBloc,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: MediaQuery.of(context).size.height / 1.618,
              flexibleSpace: FlexibleSpaceBar(
                background: PageView.builder(
                  itemBuilder: (context, index) => Calendar(
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
                  decoration: BoxDecoration(
                    color: themeData.primaryColorDark,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: SleepRecordChart(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zaza/extensions.dart';
import 'package:zaza/constants.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final _today = DateTime.now();
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _today.toYearMonthIndex);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themData = Theme.of(context);
    final saturdayTextStyle = TextStyle(
        fontWeight: FontWeight.w600, color: themData.primaryColorDark);
    final sundayTextStyle =
        TextStyle(fontWeight: FontWeight.w600, color: themData.accentColor);

    Widget _getDayText(int day, int weekDay, bool isToday) {
      if (isToday)
        return Text(
          "$day",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        );

      switch (weekDay) {
        case 7:
          return Text(
            "$day",
            style: sundayTextStyle,
          );
        case 6:
          return Text(
            "$day",
            style: saturdayTextStyle,
          );
        default:
          return Text("$day");
      }
    }

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
              color: themData.primaryColorLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(Strings.monday),
                  Text(Strings.tuesday),
                  Text(Strings.wednesday),
                  Text(Strings.thursday),
                  Text(Strings.friday),
                  Text(Strings.saturday, style: saturdayTextStyle),
                  Text(Strings.sunday, style: sundayTextStyle),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: themData.scaffoldBackgroundColor,
                    expandedHeight:
                        MediaQuery.of(context).size.width * 6 / 7 / 0.9,
                    flexibleSpace: FlexibleSpaceBar(
                      background: PageView.builder(
                        itemBuilder: (context, index) {
                          final dateFromIndex =
                              YearMonthIndexConverter.fromYearMonthIndex(index);

                          final weekDay = dateFromIndex.weekday - 2;
                          final endDay = DateTime(dateFromIndex.year,
                                  dateFromIndex.month + 1, 0)
                              .day;

                          return GridView.count(
                            crossAxisCount: 7,
                            childAspectRatio: 0.9,
                            children: List.generate(42, (index) {
                              final day = index - weekDay;
                              final isToday = _isToday(DateTime(
                                  dateFromIndex.year,
                                  dateFromIndex.month,
                                  day));

                              return Container(
                                margin: EdgeInsets.all(4),
                                child: FlatButton(
                                  shape: CircleBorder(),
                                  color: isToday
                                      ? themData.accentColor
                                      : Colors.transparent,
                                  onPressed:
                                      day > 0 && day < endDay ? () {} : null,
                                  child: day > 0 && day < endDay
                                      ? _getDayText(day, index % 7 + 1, isToday)
                                      : null,
                                ),
                              );
                            }),
                          );
                        },
                        controller: _pageController,
                      ),
                    ),
                  ),
                  SliverGrid.count(
                    crossAxisCount: 1,
                    children: <Widget>[
                      Container(
                        color: themData.primaryColorDark,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }

  bool _isToday(DateTime date) =>
      _today.year == date.year &&
      _today.month == date.month &&
      _today.day == date.day;
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
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorLight,
              fontSize: 18),
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

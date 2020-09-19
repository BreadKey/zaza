part of 'package:zaza/screens/calendar.dart';

class MonthMover extends StatefulWidget {
  final PageController _controller;

  const MonthMover({Key key, @required PageController controller})
      : assert(controller != null),
        _controller = controller,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _MonthMoverState();
}

class _MonthMoverState extends State<MonthMover> {
  DateTime _currentDate;

  _MonthMoverState();

  Function() _controllerListener;

  @override
  void initState() {
    super.initState();
    _currentDate = YearMonthIndexConverter.fromYearMonthIndex(
        widget._controller.initialPage);
    _controllerListener = () {
      setState(() {
        _currentDate = YearMonthIndexConverter.fromYearMonthIndex(
            widget._controller.page.round());
      });
    };
    widget._controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    widget._controller.removeListener(_controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = _currentDate.toYearMonthIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: ZazaColors.bread,
            ),
            onPressed: () {
              widget._controller.animateToPage(--currentIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            }),
        Text(
          "${_currentDate?.year}.${_currentDate?.month}",
          style: Theme.of(context).textTheme.subtitle2,
        ),
        IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: ZazaColors.bread,
            ),
            onPressed: () {
              widget._controller.animateToPage(++currentIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            }),
      ],
    );
  }
}

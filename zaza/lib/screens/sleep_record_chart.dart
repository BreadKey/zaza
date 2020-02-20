part of 'home_page.dart';

class _SleepRecordChart extends StatefulWidget {
  final SleepRecordBloc _sleepRecordBloc;

  const _SleepRecordChart(this._sleepRecordBloc);

  @override
  State<StatefulWidget> createState() =>
      _SleepRecordChartState(_sleepRecordBloc);
}

class _SleepRecordChartState extends State<_SleepRecordChart>
    with SingleTickerProviderStateMixin {
  final SleepRecordBloc _sleepRecordBloc;
  List<SleepRecord> _sleepRecords = [];
  List<MapEntry<int, double>> _conditionScoresByHours = [];
  List<double> _angles = [];

  _SleepRecordChartState(this._sleepRecordBloc);

  int _firstScoreIndex = 0;

  AnimationController _rotateAnimController;
  Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _rotateAnimController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _rotateAnimation =
        CurvedAnimation(parent: _rotateAnimController, curve: Curves.bounceOut);

    _sleepRecordBloc.getAll().then((sleepRecords) {
      setState(() {
        _sleepRecords = sleepRecords;
        _calculateConditionScoreByHours();
      });
    });

    _sleepRecordBloc.editedSleepRecord.listen((editedSleepRecord) {
      setState(() {
        _sleepRecords.removeWhere((sleepRecord) =>
            sleepRecord.monthIndex == editedSleepRecord.monthIndex &&
            sleepRecord.day == editedSleepRecord.day);
        _sleepRecords.add(editedSleepRecord);
      });

      _sleepRecordBloc.removedSleepRecord.listen((removedSleepRecord) {
        setState(() {
          _sleepRecords.remove(removedSleepRecord);
        });
      });
    });
  }

  @override
  void dispose() {
    _rotateAnimController.dispose();
    super.dispose();
  }

  void _calculateConditionScoreByHours() {
    if (_sleepRecords.isEmpty) return;

    _conditionScoresByHours.clear();

    final sleepRecordMapByHours = Map<int, List<SleepRecord>>();

    for (final sleepRecord in _sleepRecords) {
      if (sleepRecordMapByHours[sleepRecord.sleepHours] == null) {
        sleepRecordMapByHours[sleepRecord.sleepHours] = [];
      }

      sleepRecordMapByHours[sleepRecord.sleepHours].add(sleepRecord);
    }

    sleepRecordMapByHours.forEach((sleepHours, sleepRecords) {
      _conditionScoresByHours.add(MapEntry(
          sleepHours,
          sleepRecords
                  .map((sleepRecord) => sleepRecord.conditionScore)
                  .reduce((acc, score) => acc + score) /
              sleepRecords.length));
    });

    _conditionScoresByHours.sort((a, b) => a.value < b.value ? 1 : 0);

    final sum = _conditionScoresByHours
        .map((average) => average.value)
        .reduce((acc, average) => acc + average);

    _angles = _conditionScoresByHours
        .map((average) => 2 * pi * average.value / sum)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Stack(
      children: <Widget>[
        SizedBox.expand(
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _SleepRecordPieChart(_conditionScoresByHours, _angles,
                    _firstScoreIndex, _rotateAnimController.isAnimating ? _rotateAnimation.value : 1.0),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: themeData.accentColor,
              ),
              onPressed: _sleepRecords.isEmpty
                  ? null
                  : () {
                      _rotateAnimController.forward(from: 0.0);
                      setState(() {
                        _firstScoreIndex--;
                      });
                    },
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: themeData.accentColor,
              ),
              onPressed: _sleepRecords.isEmpty
                  ? null
                  : () {
                      _rotateAnimController.forward(from: 0.0);
                      setState(() {
                        _firstScoreIndex++;
                      });
                    },
            )
          ],
        )
      ],
    );
  }
}

class _SleepRecordPieChart extends CustomPainter {
  static const quarterRadian = pi / 2;
  static const smallAngle = pi * (30 / 180);

  final List<MapEntry<int, double>> conditionScoreAverages;
  int firstScoreIndex;

  final List<double> angles;

  final double _animationRatio;

  _SleepRecordPieChart(this.conditionScoreAverages, this.angles,
      this.firstScoreIndex, this._animationRatio) {
    if (angles.isEmpty) return;

    firstScoreIndex = firstScoreIndex % angles.length;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (angles.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(center.dx, center.dy) * 0.8);
    final holeRadius = radius * 0.6;
    final textRadius = (radius + holeRadius) / 2;
    final textCenter = Offset(0.0, textRadius);
    final fontSize = radius * 0.11;
    final strokeWidth = radius * 0.02;

//    print(firstScoreIndex);
    double beginAngle = 0.0;

    final sumOfBeforeAngles = firstScoreIndex == 0
        ? 0.0
        : angles
            .sublist(0, firstScoreIndex)
            .reduce((acc, angle) => acc + angle);
    double endAngle =
        - pi / 2 - sumOfBeforeAngles - (angles[firstScoreIndex] / 2) *
            _animationRatio;

    bool textAtSmallPositionToggle = false;

    final medianAngles = <double>[];
    final scores = <double>[];

    int index = 0;
    for (final angle in angles) {
      beginAngle = endAngle;
      endAngle = beginAngle + angle;

      final medianAngle = (beginAngle + endAngle) / 2;
      medianAngles.add(medianAngle);

      final score = conditionScoreAverages[index].value;
      scores.add(score);

      final offset = Offset(cos(medianAngle), sin(medianAngle));

      final piePath = Path()
        ..moveTo(center.dx + offset.dx, center.dy + offset.dy)
        ..arcTo(Rect.fromCircle(center: center + offset, radius: radius),
            beginAngle, angle, true)
        ..arcTo(Rect.fromCircle(center: center + offset, radius: holeRadius),
            endAngle, -angle, false)
        ..close();

      canvas.drawPath(piePath, Paint()..color = getDayColor(score));

      index++;
    }

    index = 0;
    for (final angle in angles) {
      textAtSmallPositionToggle = !textAtSmallPositionToggle;

      final hours = conditionScoreAverages[index].key;

      final score = scores[index];
      final medianAngle = medianAngles[index];

      final finalTextRadius = angle > smallAngle
          ? textRadius
          : textAtSmallPositionToggle ? radius : holeRadius;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(medianAngle);
      canvas.translate(finalTextRadius, 0.0);
      canvas.rotate(quarterRadian);

      final text =
          "$hours${Strings.hourSuffix}\n${score.round()}${Strings.scoreSuffix}";

      final textStrokePainter = TextPainter(
          text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..strokeWidth = strokeWidth
                  ..color = Colors.black
                  ..style = PaintingStyle.stroke,
              )),
          textDirection: TextDirection.ltr)
        ..layout();

      textStrokePainter.paint(canvas,
          Offset(-textStrokePainter.width / 2, -textStrokePainter.height / 2));

      final textFillPainter = TextPainter(
          text: TextSpan(
              text: text,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = RadialGradient(colors: [
                      Colors.grey,
                      Colors.white
                    ], stops: [
                      0.0,
                      0.8
                    ]).createShader(
                        Rect.fromCircle(center: textCenter, radius: radius)))),
          textDirection: TextDirection.ltr)
        ..layout();

      textFillPainter.paint(canvas,
          Offset(-textFillPainter.width / 2, -textFillPainter.height / 2));

      canvas.restore();

      index++;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

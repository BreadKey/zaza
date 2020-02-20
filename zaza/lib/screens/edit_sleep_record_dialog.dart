part of 'home_page.dart';

class _EditSleepRecordDialog extends StatefulWidget {
  final SleepRecord sleepRecord;
  final int monthIndex;
  final int day;
  final Function(SleepRecord) _onEditCompleted;

  const _EditSleepRecordDialog(this.sleepRecord, this.monthIndex, this.day,
      {Function(SleepRecord) onEditCompleted})
      : this._onEditCompleted = onEditCompleted;

  @override
  State<StatefulWidget> createState() =>
      _EditSleepRecordState(sleepRecord, monthIndex, day, _onEditCompleted);
}

class _EditSleepRecordState extends State<_EditSleepRecordDialog> {
  static final _nanRegExp = RegExp("^[0-9]");
  final _formKey = GlobalKey<FormState>();

  final SleepRecord sleepRecord;
  final int monthIndex;
  final int day;
  final Function(SleepRecord) onEditCompleted;

  bool _validated = false;

  FocusNode _conditionFocusNode;

  TextEditingController _sleepHoursTextController;
  TextEditingController _conditionScoreTextController;

  _EditSleepRecordState(
      this.sleepRecord, this.monthIndex, this.day, this.onEditCompleted);

  @override
  void initState() {
    super.initState();
    _conditionFocusNode = FocusNode();
    _sleepHoursTextController =
        TextEditingController(text: "${sleepRecord?.sleepHours ?? ""}");
    _conditionScoreTextController =
        TextEditingController(text: "${sleepRecord?.conditionScore ?? ""}");
  }

  @override
  void dispose() {
    _conditionFocusNode.dispose();
    _sleepHoursTextController.dispose();
    _conditionScoreTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Strings.editSleepRecordTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _sleepHoursTextController,
              autofocus: true,
              decoration: InputDecoration(
                  icon: Icon(Icons.watch_later), labelText: Strings.sleepTime),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_isNaN(value))
                  return Strings.pleaseEnterOnlyNumber;
                return null;
              },
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_conditionFocusNode);
              },
            ),
            TextFormField(
              controller: _conditionScoreTextController,
              focusNode: _conditionFocusNode,
              decoration: InputDecoration(
                  icon: Icon(Icons.mood), labelText: Strings.condition),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_isNaN(value))
                  return Strings.pleaseEnterOnlyNumber;
                else {
                  final score = int.parse(value);

                  if (score > 100) {
                    return Strings.pleaseEnterCorrectScore;
                  }
                }

                return null;
              },
              onFieldSubmitted: (value) {
                setState(() {
                  _validated = _formKey.currentState.validate();
                });
              },
            )
          ],
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: _validated
              ? () {
            setState(() {
              _validated = false;
            });
            onEditCompleted(SleepRecord(monthIndex, day,
                sleepHours: int.parse(_sleepHoursTextController.text),
                conditionScore: int.parse(_conditionScoreTextController.text)));
          }
              : null,
        )
      ],
    );
  }

  bool _isNaN(String value) => _nanRegExp.hasMatch(value) || value.contains("-");
}
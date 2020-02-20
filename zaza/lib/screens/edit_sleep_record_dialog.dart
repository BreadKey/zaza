part of 'home_page.dart';

class _EditSleepRecordDialog extends StatefulWidget {
  final SleepRecord sleepRecord;
  final int monthIndex;
  final int day;
  final Function(SleepRecord) _onEditCompleted;
  final Function(SleepRecord) _onRemoved;

  const _EditSleepRecordDialog(this.sleepRecord, this.monthIndex, this.day,
      {Function(SleepRecord) onEditCompleted, Function(SleepRecord) onRemoved})
      : this._onEditCompleted = onEditCompleted,
        this._onRemoved = onRemoved;

  @override
  State<StatefulWidget> createState() =>
      _EditSleepRecordState(sleepRecord, monthIndex, day, _onEditCompleted, _onRemoved);
}

class _EditSleepRecordState extends State<_EditSleepRecordDialog> {
  static final _nanRegExp = RegExp(r"['.'',' ]");
  final _formKey = GlobalKey<FormState>();

  SleepRecord sleepRecord;
  final int monthIndex;
  final int day;
  final Function(SleepRecord) onEditCompleted;
  final Function(SleepRecord) onRemoved;

  final SleepRecordRepository _sleepRecordRepository = SleepRecordRepository();

  bool _validated = false;

  FocusNode _conditionFocusNode;

  TextEditingController _sleepHoursTextController;
  TextEditingController _conditionScoreTextController;

  _EditSleepRecordState(
      this.sleepRecord, this.monthIndex, this.day, this.onEditCompleted, this.onRemoved);

  @override
  void initState() {
    super.initState();
    _conditionFocusNode = FocusNode();
    _sleepHoursTextController =
        TextEditingController(text: sleepRecord?.sleepHours?.toString());
    _conditionScoreTextController =
        TextEditingController(text: sleepRecord?.conditionScore?.toString());
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
              textAlign: TextAlign.right,
              controller: _sleepHoursTextController,
              autofocus: true,
              decoration: InputDecoration(
                  icon: Icon(Icons.watch_later), labelText: Strings.sleepTime, suffixText: Strings.hourSuffix),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_isNaN(value)) return Strings.pleaseEnterOnlyNumber;
                return null;
              },
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_conditionFocusNode);
              },
            ),
            TextFormField(
              textAlign: TextAlign.right,
              controller: _conditionScoreTextController,
              focusNode: _conditionFocusNode,
              decoration: InputDecoration(
                  icon: Icon(Icons.mood), labelText: Strings.condition, hintText: "0~100", suffixText: Strings.scoreSuffix),
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
          icon: Icon(Icons.delete_forever),
          onPressed: sleepRecord == null ? null : () {
            final sleepRecord = this.sleepRecord;

            setState(() {
              this.sleepRecord = null;
            });

            _sleepRecordRepository.remove(sleepRecord).then((_) {
              onRemoved(sleepRecord);
            });
          },
        ),

        IconButton(
          icon: Icon(Icons.edit),
          onPressed: _validated
              ? () {
                  setState(() {
                    _validated = false;
                  });

                  if (_formKey.currentState.validate()) {
                    final sleepRecord = SleepRecord(monthIndex, day,
                        sleepHours: int.parse(_sleepHoursTextController.text),
                        conditionScore:
                            int.parse(_conditionScoreTextController.text));

                    _sleepRecordRepository.update(sleepRecord).then((_) {
                      onEditCompleted(sleepRecord);
                    });
                  }
                }
              : null,
        )
      ],
    );
  }

  bool _isNaN(String value) =>
      _nanRegExp.hasMatch(value) || value.contains("-") || value.isEmpty;
}

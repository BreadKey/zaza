import 'package:flutter/material.dart';
import 'package:zaza/blocs/sleep_record_bloc.dart';
import 'package:zaza/constants.dart';
import 'package:zaza/models/sleep_record.dart';

class EditSleepRecordDialog extends StatefulWidget {
  final SleepRecordBloc sleepRecordBloc;
  final SleepRecord sleepRecord;
  final int monthIndex;
  final int day;

  const EditSleepRecordDialog(
      this.sleepRecordBloc, this.sleepRecord, this.monthIndex, this.day);

  @override
  State<StatefulWidget> createState() => _EditSleepRecordState();
}

class _EditSleepRecordState extends State<EditSleepRecordDialog> {
  static final _nanRegExp = RegExp(r"['.'',' ]");
  final _formKey = GlobalKey<FormState>();

  FocusNode _conditionFocusNode;

  TextEditingController _sleepHoursTextController;
  TextEditingController _conditionScoreTextController;
  SleepRecord _sleepRecord;

  @override
  void initState() {
    super.initState();
    _conditionFocusNode = FocusNode();
    _sleepRecord = widget.sleepRecord;
    _sleepHoursTextController =
        TextEditingController(text: _sleepRecord?.sleepHours?.toString());
    _conditionScoreTextController = TextEditingController(
        text: widget.sleepRecord?.conditionScore?.toString());
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
                decoration: const InputDecoration(
                    icon: Icon(Icons.watch_later),
                    labelText: Strings.sleepTime,
                    suffixText: Strings.hourSuffix),
                keyboardType: TextInputType.number,
                validator: _validateSleepHour,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_conditionFocusNode);
                }),
            TextFormField(
                textAlign: TextAlign.right,
                controller: _conditionScoreTextController,
                focusNode: _conditionFocusNode,
                decoration: const InputDecoration(
                    icon: Icon(Icons.mood),
                    labelText: Strings.condition,
                    hintText: "0~100",
                    suffixText: Strings.scoreSuffix),
                keyboardType: TextInputType.number,
                validator: _validateConditionScore)
          ],
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.delete_forever,
          ),
          color: Colors.redAccent,
          onPressed: widget.sleepRecord == null
              ? null
              : () {
                  setState(() {
                    _sleepRecord = null;
                  });

                  widget.sleepRecordBloc.remove(widget.sleepRecord);
                  Navigator.of(context).pop();
                },
        ),
        IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                final sleepRecord = SleepRecord(widget.monthIndex, widget.day,
                    sleepHours: int.parse(_sleepHoursTextController.text),
                    conditionScore:
                        int.parse(_conditionScoreTextController.text));

                widget.sleepRecordBloc.update(sleepRecord).then((_) {
                  Navigator.of(context).pop();
                });
              }
            })
      ],
    );
  }

  bool _isNaN(String value) =>
      _nanRegExp.hasMatch(value) || value.contains("-") || value.isEmpty;

  String _validateSleepHour(String sleepHour) {
    if (_isNaN(sleepHour)) return Strings.pleaseEnterOnlyNumber;
    return null;
  }

  String _validateConditionScore(String conditationScore) {
    if (_isNaN(conditationScore))
      return Strings.pleaseEnterOnlyNumber;
    else {
      final score = int.parse(conditationScore);

      if (score > 100) {
        return Strings.pleaseEnterCorrectScore;
      }
    }

    return null;
  }
}

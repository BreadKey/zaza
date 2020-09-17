import 'package:rxdart/rxdart.dart';
import 'package:zaza/models/sleep_record.dart';

class SleepRecordBloc {
  final _sleepRecordRepository = SleepRecordRepository();

  final _editedSleepRecord = PublishSubject<SleepRecord>();

  Stream<SleepRecord> get editedSleepRecord => _editedSleepRecord.stream;

  final _removedSleepRecord = PublishSubject<SleepRecord>();

  Stream<SleepRecord> get removedSleepRecord => _removedSleepRecord.stream;

  Future<List<SleepRecord>> getAll() => _sleepRecordRepository.getAll();

  Future<List<SleepRecord>> findByMonthIndex(int monthIndex) =>
      _sleepRecordRepository.findByMonthIndex(monthIndex);

  Future<void> update(SleepRecord sleepRecord) =>
      _sleepRecordRepository.update(sleepRecord).then((_) {
        _editedSleepRecord.sink.add(sleepRecord);
      });

  Future<void> remove(SleepRecord sleepRecord) =>
      _sleepRecordRepository.remove(sleepRecord).then((_) {
        _removedSleepRecord.sink.add(sleepRecord);
      });

  void dispose() {
    _editedSleepRecord.close();
    _removedSleepRecord.close();
  }
}

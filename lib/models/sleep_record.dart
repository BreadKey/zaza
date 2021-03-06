import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SleepRecord {
  final int monthIndex;
  final int day;
  int sleepHours;
  int conditionScore;

  SleepRecord(this.monthIndex, this.day,
      {this.sleepHours, this.conditionScore});

  factory SleepRecord.fromJson(Map<String, dynamic> json) =>
      SleepRecord(json["month_index"], json["day"],
          sleepHours: json["sleep_hours"],
          conditionScore: json["condition_score"]);

  Map<String, dynamic> toJson() =>
      {
        "month_index": monthIndex,
        "day": day,
        "sleep_hours": sleepHours,
        "condition_score": conditionScore
      };

  @override
  int get hashCode => monthIndex ^ day;

  @override
  bool operator ==(other) {
    return other.hashCode == hashCode;
  }
}

abstract class SleepRecordRepository {
  static final SleepRecordRepository _singleton =
  SleepRecordRepository._local();

  factory SleepRecordRepository() => _singleton;

  factory SleepRecordRepository._local() => _LocalSleepRepository();

  Future<List<SleepRecord>> getAll();

  Future<List<SleepRecord>> findByMonthIndex(int monthIndex);

  Future<void> update(SleepRecord sleepRecord);

  Future<void> remove(SleepRecord sleepRecord);
}

class _LocalSleepRepository implements SleepRecordRepository {
  Future<Database> database;

  _LocalSleepRepository() {
    database = _initDatabase();
  }

  Future<Database> _initDatabase() async =>
      openDatabase(
        join(await getDatabasesPath(), "sleep_record_database.db"),
        onCreate: (db, version) {
          return db.execute(
              "CREATE TABLE sleep_records(month_index INTEGER, day INTEGER, sleep_hours INTEGER, condition_score INTEGER)");
        },
        version: 1,
      );

  @override
  Future<List<SleepRecord>> getAll() async {
    final db = await database;

    return db.query("sleep_records").then((maps) =>
        List.generate(
            maps.length, (index) => SleepRecord.fromJson(maps[index])));
  }

  @override
  Future<List<SleepRecord>> findByMonthIndex(int monthIndex) async {
    final db = await database;

    return db.query("sleep_records", where: "month_index = ?", whereArgs: [
      monthIndex
    ]).then((maps) =>
        List.generate(
            maps.length, (index) => SleepRecord.fromJson(maps[index])));
  }

  @override
  Future<void> update(SleepRecord sleepRecord) async {
    final db = await database;
    final exist = await db.query("sleep_records",
        where: "month_index = ? AND day = ?",
        whereArgs: [sleepRecord.monthIndex, sleepRecord.day]);

    if (exist.isEmpty) {
      return db.insert("sleep_records", sleepRecord.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      return db.update("sleep_records", sleepRecord.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
          where: "month_index = ? AND day = ?",
          whereArgs: [sleepRecord.monthIndex, sleepRecord.day]);
    }
  }

  @override
  Future<void> remove(SleepRecord sleepRecord) async {
    final db = await database;

    return db.delete("sleep_records",
        where: "month_index = ? AND day = ?",
        whereArgs: [sleepRecord.monthIndex, sleepRecord.day]);
  }
}

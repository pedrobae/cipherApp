import 'package:cordis/helpers/database.dart';
import 'package:cordis/models/domain/schedule.dart';

class LocalScheduleRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // ===== CREATE =====
  // ===== READ =====
  /// Retrieves all schedules from the local database.
  Future<List<Schedule>> getAllSchedules() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('schedule');

    return List.from(maps.map((map) => Schedule.fromSqlite(map)));
  }

  // ===== UPDATE =====
  // ===== DELETE =====
}

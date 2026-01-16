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

    List<Schedule> schedules = [];
    for (var map in maps) {
      final scheduleId = map['id'] as int;
      final roles = await getRolesForSchedule(scheduleId);
      schedules.add(Schedule.fromSqlite(map, roles));
    }

    return schedules;
  }

  Future<Schedule?> getScheduleById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedule',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final scheduleId = maps.first['id'] as int;
    final roles = await getRolesForSchedule(scheduleId);
    return Schedule.fromSqlite(maps.first, roles);
  }

  Future<List<Role>> getRolesForSchedule(int scheduleId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'role',
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
    );

    List<Role> roles = [];
    for (var map in maps) {
      final roleId = map['id'] as int;
      final memberIds = await getMemberIdsForRole(roleId);
      roles.add(Role.fromSqlite(map, memberIds));
    }

    return roles;
  }

  Future<List<int>> getMemberIdsForRole(int roleId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'role_member',
      where: 'role_id = ?',
      whereArgs: [roleId],
    );

    List<int> memberIds = [];
    for (var map in maps) {
      memberIds.add(map['member_id'] as int);
    }

    return memberIds;
  }

  // ===== UPDATE =====
  // ===== DELETE =====
}

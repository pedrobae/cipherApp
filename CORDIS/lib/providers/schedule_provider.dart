import 'package:cordis/models/domain/schedule.dart';
import 'package:cordis/repositories/local_schedule_repository.dart';
import 'package:flutter/foundation.dart';

class ScheduleProvider extends ChangeNotifier {
  final LocalScheduleRepository _localScheduleRepository =
      LocalScheduleRepository();

  ScheduleProvider();

  Map<int, Schedule> _schedules = {};

  String? _error;

  bool _isLoading = false;
  bool _isLoadingCloud = false;

  // Getters
  Map<int, Schedule> get schedules => _schedules;
  Schedule? getScheduleById(int id) {
    return _schedules[id];
  }

  Schedule? getNextSchedule() {
    try {
      return _schedules.values.firstWhere(
        (schedule) => schedule.date.isAfter(DateTime.now()),
      );
    } catch (e) {
      return null;
    }
  }

  String? getUserRoleInSchedule(int scheduleId, int? localUserId) {
    if (localUserId == null) return null;

    final schedule = getScheduleById(scheduleId);
    if (schedule == null) return null;

    for (var role in schedule.roles) {
      if (role.memberIds.contains(localUserId)) {
        return role.name;
      }
    }
    return null;
  }

  String? get error => _error;

  bool get isLoading => _isLoading;
  bool get isLoadingCloud => _isLoadingCloud;

  // ===== CREATE =====
  // ===== READ =====
  /// Loads schedules from the local repository.
  Future<void> loadSchedules() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final scheduleList = await _localScheduleRepository.getAllSchedules();
      _schedules = {for (var schedule in scheduleList) schedule.id: schedule};
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== UPDATE =====
  // ===== DELETE =====

  // ===== HELPER METHODS =====
}

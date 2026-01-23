import 'package:cordis/models/domain/playlist/playlist.dart';
import 'package:cordis/models/domain/schedule.dart';
import 'package:cordis/models/dtos/schedule_dto.dart';
import 'package:cordis/repositories/local_schedule_repository.dart';
import 'package:flutter/material.dart';

class ScheduleProvider extends ChangeNotifier {
  final LocalScheduleRepository _localScheduleRepository =
      LocalScheduleRepository();

  ScheduleProvider();

  Map<dynamic, dynamic> _schedules =
      {}; // Map<int/String, Schedule/ScheduleDTO>
  Map<dynamic, dynamic> _filteredSchedules = {};

  String? _searchTerm;

  String? _error;

  bool _isLoading = false;
  bool _isLoadingCloud = false;
  bool _isSaving = false;
  // bool _isSavingToCloud = false;

  // Getters
  Map<dynamic, dynamic> get schedules => _schedules;

  Map<dynamic, dynamic> get filteredSchedules => _filteredSchedules;

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
  void cacheBrandNewSchedule(Playlist playlist, String ownerFirebaseId) {
    _schedules[-1] = Schedule(
      id: -1,
      ownerFirebaseId: ownerFirebaseId,
      name: '',
      date: DateTime.fromMicrosecondsSinceEpoch(0),
      time: TimeOfDay(hour: 0, minute: 0),
      location: '',
      playlist: playlist,
      roles: [],
    );
  }

  void cacheScheduleDetails({
    required String name,
    required DateTime date,
    required TimeOfDay time,
    required String location,
    String? notes,
  }) {
    final schedule = _schedules[-1] as Schedule;
    _schedules[-1] = Schedule(
      id: schedule.id,
      ownerFirebaseId: schedule.ownerFirebaseId,
      name: name,
      date: date,
      time: time,
      location: location,
      playlist: schedule.playlist,
      roles: schedule.roles,
      notes: notes,
    );
  }

  Future<bool> createFromCache() async {
    if (_isSaving) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final schedule = _schedules[-1] as Schedule;

      final localId = await _localScheduleRepository.insertSchedule(schedule);
      _schedules.remove(-1);

      await loadLocalSchedule(localId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    if (_error == null) {
      return true;
    } else {
      return false;
    }
  }

  // ===== READ =====
  /// Loads schedules from the local repository.
  Future<void> loadLocalSchedules() async {
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

  Future<void> loadLocalSchedule(int id) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final schedule = await _localScheduleRepository.getScheduleById(id);
      if (schedule != null) {
        _schedules[id] = schedule;
      } else {
        _error = 'Schedule not found';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCloudSchedules() async {
    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {} catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingCloud = false;
      notifyListeners();
    }
  }

  // ===== UPDATE =====
  // ===== DELETE =====

  // ===== SEARCH & FILTER =====
  void setSearchTerm(String? term) {
    _searchTerm = term?.toLowerCase();
    _filterSchedules();
  }

  void _filterSchedules() {
    if (_searchTerm == null || _searchTerm!.isEmpty) {
      _filteredSchedules = _schedules;
    } else {
      Map<dynamic, dynamic> tempFiltered = {};
      for (var entry in _schedules.entries) {
        final dynamic schedule;
        if (entry.key.runtimeType == int) {
          schedule = entry.value as Schedule;
        } else {
          schedule = entry.value as ScheduleDto;
        }

        if (schedule.name.toLowerCase().contains(_searchTerm!) ||
            schedule.location.toLowerCase().contains(_searchTerm!)) {
          tempFiltered[entry.key] = schedule;
        }
      }
      _filteredSchedules = tempFiltered;
    }
    notifyListeners();
  }

  // ===== HELPER METHODS =====
  List<dynamic> getNextThisMonthsSchedules() {
    List<dynamic> thisMonthsScheduleIds = [];
    final now = DateTime.now();
    _schedules.forEach((key, schedule) {
      bool isCloud = key.runtimeType == String;

      final scheduleDate = isCloud
          ? (schedule as ScheduleDto).datetime.toDate()
          : (schedule as Schedule).date;
      if (scheduleDate.isAfter(now) &&
          scheduleDate.year == now.year &&
          scheduleDate.month == now.month) {
        thisMonthsScheduleIds.add(key);
      }
    });
    return thisMonthsScheduleIds;
  }
}

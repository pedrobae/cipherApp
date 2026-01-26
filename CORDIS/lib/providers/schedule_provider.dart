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

  /// Returns a schedule by its ID, whether local (int) or cloud (String)
  /// Returns null if not found.
  /// Returns Schedule for local IDs and ScheduleDTO for cloud IDs.
  dynamic getScheduleById(dynamic id) {
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

  void cacheScheduleDetails(
    dynamic scheduleId, {
    required String name,
    required DateTime date,
    required TimeOfDay startTime,
    required String location,
    String? annotations,
  }) {
    final schedule = _schedules[-1] as Schedule;
    _schedules[-1] = Schedule(
      id: schedule.id,
      ownerFirebaseId: schedule.ownerFirebaseId,
      name: name,
      date: date,
      time: startTime,
      location: location,
      playlist: schedule.playlist,
      roles: schedule.roles,
      annotations: annotations,
    );
  }

  Future<bool> createFromCache(String ownerFirebaseId) async {
    if (_isSaving) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final schedule = _schedules[-1] as Schedule;

      final localId = await _localScheduleRepository.insertSchedule(
        schedule.copyWith(ownerFirebaseId: ownerFirebaseId),
      );
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
  void addRoleToSchedule(dynamic scheduleId, String roleName) {
    final schedule = _schedules[scheduleId];
    if (schedule == null) return;

    if (scheduleId is int) {
      final newRole = Role(id: -1, name: roleName, memberIds: []);
      (_schedules[scheduleId] as Schedule).roles.add(newRole);
    }

    notifyListeners();
  }

  // ===== MEMBER MANAGEMENT =====
  /// Adds an existing user to a role in a schedule (local).
  void addMemberToRole(int scheduleId, int roleId, int userId) {
    final schedule = _schedules[scheduleId] as Schedule?;
    if (schedule == null) return;

    final role = schedule.roles.firstWhere((role) => role.id == roleId);

    role.memberIds.add(userId);
    notifyListeners();
  }

  void addUnknownMemberToRole(
    int scheduleId,
    int roleId,
    String username,
    String email,
  ) {
    // TODO: Implement adding unknown member to role in local schedule
  }

  void addMemberToRoleFirebase(
    String scheduleId,
    String roleName,
    String existingUserFirebaseId,
  ) {
    final schedule = _schedules[scheduleId] as ScheduleDto?;
    if (schedule == null) return;

    final role = schedule.roles.firstWhere((role) => role.name == roleName);

    role.memberIds.add(existingUserFirebaseId);
    notifyListeners();
  }

  void addUnknownMemberToRoleFirebase(
    String scheduleId,
    String roleId,
    String username,
    String email,
  ) {
    // TODO : Implement adding unknown member to role in cloud schedule
  }

  // ===== DELETE =====
  /// Deletes a role from a schedule (local).
  /// Also removes all members assigned to that role.
  void deleteRole(int scheduleId, int roleId) {
    final schedule = _schedules[scheduleId] as Schedule?;
    if (schedule == null || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      schedule.roles.removeWhere((role) => role.id == roleId);

      if (roleId != -1) _localScheduleRepository.deleteRole(roleId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
        final schedule = entry.value;

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
  List<dynamic> getNextScheuleIds() {
    List<dynamic> nextScheduleIds = [];
    final now = DateTime.now();
    _schedules.forEach((key, schedule) {
      bool isCloud = key.runtimeType == String;

      final scheduleDate = isCloud
          ? (schedule as ScheduleDto).datetime.toDate()
          : (schedule as Schedule).date;
      if (scheduleDate.isAfter(now)) {
        nextScheduleIds.add(key);
      }
    });
    return nextScheduleIds;
  }
}

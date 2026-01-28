import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordis/models/domain/schedule.dart';
import 'package:cordis/models/dtos/schedule_dto.dart';
import 'package:cordis/repositories/cloud_schedule_repository.dart';
import 'package:cordis/repositories/local_schedule_repository.dart';
import 'package:flutter/material.dart';

class ScheduleProvider extends ChangeNotifier {
  final LocalScheduleRepository _localScheduleRepository =
      LocalScheduleRepository();
  final CloudScheduleRepository _cloudScheduleRepository =
      CloudScheduleRepository();

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
  void cacheBrandNewSchedule(int playlistId, String ownerFirebaseId) {
    _schedules[-1] = Schedule(
      id: -1,
      ownerFirebaseId: ownerFirebaseId,
      name: '',
      date: DateTime.fromMicrosecondsSinceEpoch(0),
      time: TimeOfDay(hour: 0, minute: 0),
      location: '',
      playlistId: playlistId,
      roles: [],
    );
  }

  void cacheNewScheduleDetails({
    required String name,
    required String date,
    required String startTime,
    required String location,
    String? annotations,
  }) {
    _schedules[-1] = (_schedules[-1] as Schedule).copyWith(
      name: name,
      date: DateTime(
        int.parse(date.split('/')[2]),
        int.parse(date.split('/')[1]),
        int.parse(date.split('/')[0]),
      ),
      time: TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]),
      ),
      location: location,
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

  Future<void> fetchSchedule(String scheduleId) async {
    if (_isLoadingCloud) return;

    _isLoadingCloud = true;
    _error = null;
    notifyListeners();

    try {
      final schedule = await _cloudScheduleRepository.fetchScheduleById(
        scheduleId,
      );
      if (schedule != null) {
        _schedules[scheduleId] = schedule;
      } else {
        throw Exception('Schedule not found');
      }
    } catch (e) {
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

  void updateRoleName(dynamic scheduleId, String oldName, String newName) {
    final schedule = _schedules[scheduleId];
    if (schedule == null) return;

    if (scheduleId is int) {
      final role = (schedule as Schedule).roles.firstWhere(
        (role) => role.name == oldName,
      );
      role.name = newName;
    } else if (scheduleId is String) {
      final role = (schedule as ScheduleDto).roles.firstWhere(
        (role) => role.name == oldName,
      );
      role.name = newName;
    }

    notifyListeners();
  }

  void assignPlaylistToLocalSchedule(int scheduleId, int playlistId) {
    final schedule = _schedules[scheduleId];
    if (schedule == null) return;

    _schedules[scheduleId] = (_schedules[scheduleId] as Schedule).copyWith(
      playlistId: playlistId,
    );

    notifyListeners();
  }

  void cacheScheduleDetails(
    dynamic scheduleId, {
    required String name,
    required String date,
    required String startTime,
    required String location,
    String? annotations,
  }) {
    final schedule = _schedules[scheduleId];
    if (schedule == null) return;

    if (scheduleId is int) {
      _schedules[scheduleId] = (schedule as Schedule).copyWith(
        name: name,
        date: DateTime(
          int.parse(date.split('/')[2]),
          int.parse(date.split('/')[1]),
          int.parse(date.split('/')[0]),
        ),
        time: TimeOfDay(
          hour: int.parse(startTime.split(':')[0]),
          minute: int.parse(startTime.split(':')[1]),
        ),
        location: location,
        annotations: annotations,
      );
    } else if (scheduleId is String) {
      _schedules[scheduleId] = (schedule as ScheduleDto).copyWith(
        name: name,
        datetime: Timestamp.fromDate(
          DateTime(
            int.parse(date.split('/')[0]),
            int.parse(date.split('/')[1]),
            int.parse(date.split('/')[2]),
            int.parse(startTime.split(':')[0]),
            int.parse(startTime.split(':')[1]),
          ),
        ),
        location: location,
        annotations: annotations,
      );
    }

    notifyListeners();
  }

  Future<void> saveLocalSchedule(dynamic scheduleId) async {
    if (_isSaving) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final schedule = _schedules[scheduleId];
      if (scheduleId is int && schedule is Schedule) {
        await _localScheduleRepository.updateSchedule(schedule);
      }
      // else if (scheduleId is String && schedule is ScheduleDto) {
      //   await _cloudScheduleRepository.updateSchedule(schedule);
      // }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
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

  void addMemberToRoleFirebase(
    String scheduleId,
    String
    roleName, // Cloud roles dont have IDs, as they are nested on schedules
    String existingUserFirebaseId,
  ) {
    final schedule = _schedules[scheduleId] as ScheduleDto?;
    if (schedule == null) return;

    final role = schedule.roles.firstWhere((role) => role.name == roleName);

    role.memberIds.add(existingUserFirebaseId);
    notifyListeners();
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
  List<dynamic> getNextScheduleIds() {
    List<dynamic> nextScheduleIds = [];
    final now = DateTime.now();
    _filteredSchedules.forEach((key, schedule) {
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

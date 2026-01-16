import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cordis/models/domain/schedule.dart';
import 'package:cordis/models/dtos/playlist_dto.dart';
import 'package:flutter/material.dart';

class ScheduleDto {
  final String? firebaseId;
  final String ownerFirebaseId;
  final String name;
  final Timestamp datetime;
  final String location;
  final PlaylistDto? playlist;
  final List<RoleDto> roles;

  ScheduleDto({
    this.firebaseId,
    required this.ownerFirebaseId,
    required this.name,
    required this.datetime,
    required this.location,
    this.playlist,
    required this.roles,
  });

  factory ScheduleDto.fromFirestore(Map<String, dynamic> json) {
    return ScheduleDto(
      firebaseId: json['firebaseId'] as String?,
      ownerFirebaseId: json['ownerFirebaseId'] as String,
      name: json['name'] as String,
      datetime: json['datetime'] as Timestamp,
      location: json['location'] as String,
      playlist: json['playlist'] != null
          ? PlaylistDto.fromFirestore(json['playlist'] as Map<String, dynamic>)
          : null,
      roles: (json['roles'] as List)
          .map((role) => RoleDto.fromFirestore(role))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerFirebaseId': ownerFirebaseId,
      'name': name,
      'datetime': datetime,
      'location': location,
      'playlist': playlist?.toFirestore(),
      'roles': roles.map((role) => role.toFirestore()).toList(),
    };
  }

  Schedule toDomain(int ownerLocalId, List<List<int>> roleMemberIds) {
    final dateTime = datetime.toDate();
    final schedule = Schedule(
      id: -1, // ID will be set by local database
      ownerFirebaseId: ownerFirebaseId,
      name: name,
      date: DateTime(dateTime.year, dateTime.month, dateTime.day),
      time: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      location: location,
      playlist: playlist?.toDomain([], ownerLocalId),
      roles: roles
          .asMap()
          .map(
            (index, role) =>
                MapEntry(index, role.toDomain(roleMemberIds[index])),
          )
          .values
          .toList(),
    );

    // Adiciona os papéis ao agendamento
    for (var roleDto in roles) {
      final role = roleDto.toDomain([]);
      schedule.roles.add(role);
    }

    return schedule;
  }
}

class RoleDto {
  final String name;
  final List<String> memberFirebaseIds;

  RoleDto({required this.name, required this.memberFirebaseIds});

  factory RoleDto.fromFirestore(Map<String, dynamic> json) {
    return RoleDto(
      name: json['name'] as String,
      memberFirebaseIds: List<String>.from(
        json['memberFirebaseIds'] as List<dynamic>,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'memberFirebaseIds': memberFirebaseIds};
  }

  Role toDomain(List<int> memberLocalIds) {
    final role = Role(id: -1, name: name, memberIds: memberLocalIds);
    return role;
  }
}

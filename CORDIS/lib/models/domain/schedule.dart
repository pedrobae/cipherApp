import 'package:cordis/models/domain/playlist/playlist.dart';
import 'package:flutter/material.dart';

class Schedule {
  final int id;
  final String? firebaseId;
  final String ownerFirebaseId;
  final String name;
  final DateTime date;
  final TimeOfDay time;
  final String location;
  final String? annotations;
  final Playlist? playlist;
  final List<Role> roles;

  Schedule({
    required this.id,
    this.firebaseId,
    required this.ownerFirebaseId,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.playlist,
    required this.roles,
    this.annotations,
  });

  factory Schedule.fromSqlite(Map<String, dynamic> map, List<Role> roles) {
    return Schedule(
      id: map['id'] as int,
      firebaseId: map['firebase_id'] as String?,
      ownerFirebaseId: map['owner_firebase_id'] as String,
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String),
      time: TimeOfDay(
        hour: int.parse((map['time'] as String).split(':')[0]),
        minute: int.parse((map['time'] as String).split(':')[1]),
      ),
      location: map['location'] as String,
      playlist: map['playlist'] != null
          ? Playlist.fromJson(map['playlist'] as Map<String, dynamic>)
          : null,
      roles: roles,
      annotations: map['annotations'] as String?,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'firebase_id': firebaseId,
      'owner_firebase_id': ownerFirebaseId,
      'name': name,
      'date': date.toIso8601String(),
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'location': location,
      'playlist_id': playlist?.id,
      'annotations': annotations,
    };
  }

  Schedule copyWith({
    int? id,
    String? firebaseId,
    String? ownerFirebaseId,
    String? name,
    DateTime? date,
    TimeOfDay? time,
    String? location,
    Playlist? playlist,
    List<Role>? roles,
    String? annotations,
  }) {
    return Schedule(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      ownerFirebaseId: ownerFirebaseId ?? this.ownerFirebaseId,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      playlist: playlist ?? this.playlist,
      roles: roles ?? this.roles,
      annotations: annotations ?? this.annotations,
    );
  }
}

class Role {
  final int id;
  final String name;
  final List<int> memberIds;

  Role({required this.id, required this.name, required this.memberIds});

  factory Role.fromSqlite(Map<String, dynamic> map, List<int> memberIds) {
    return Role(
      id: map['id'] as int,
      name: map['name'] as String,
      memberIds: memberIds,
    );
  }

  Map<String, dynamic> toSqlite(int scheduleId) {
    return {'name': name, 'schedule_id': scheduleId};
  }
}

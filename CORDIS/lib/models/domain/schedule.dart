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
    );
  }

  Map<String, dynamic> toSqlite(List<int> roleIds) {
    return {
      'firebase_id': firebaseId,
      'owner_id': ownerFirebaseId,
      'name': name,
      'date': date.toIso8601String(),
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'location': location,
      'playlistId': playlist?.id,
    };
  }
}

class Role {
  final String name;
  final List<int> memberIds;

  Role({required this.name, required this.memberIds});

  factory Role.fromSqlite(Map<String, dynamic> map, List<int> memberIds) {
    return Role(name: map['name'] as String, memberIds: memberIds);
  }
}

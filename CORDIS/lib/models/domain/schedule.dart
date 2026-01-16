import 'package:cordis/models/domain/playlist/playlist.dart';
import 'package:flutter/material.dart';

class Schedule {
  final int id;
  final String name;
  final DateTime date;
  final TimeOfDay time;
  final String location;
  final Playlist? playlist;
  final List<Role> roles = [];

  Schedule({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.playlist,
  });

  factory Schedule.fromSqlite(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int,
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
    );
  }

  Map<String, dynamic> toSqlite(List<int> roleIds) {
    return {
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
  final List<int> memberIds = [];

  Role({required this.name});

  void addMember(int memberId) {
    if (!memberIds.contains(memberId)) {
      memberIds.add(memberId);
    }
  }
}

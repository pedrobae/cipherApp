import 'package:sqflite/sqflite.dart';

Future<int> insertTestUser(Transaction txn) async {
  return await txn.insert('user', {
    'username': 'testuser',
    'mail': 'test@example.com',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'is_active': 1,
  });
}

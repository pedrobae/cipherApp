import '../helpers/database.dart';
import '../models/domain/user.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Get all users
  Future<List<User>> getAllUsers() async {
    final db = await _databaseHelper.database;

    final result = await db.query('user');

    return result.map((row) => User.fromJson(row)).toList();
  }

  /// Get a user by ID
  Future<User?> getUserById(int userId) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return User.fromJson(results.first);
    }

    return null;
  }

  /// Get a user by Firebase ID
  Future<User?> getUserByFirebaseId(String firebaseId) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'user',
      where: 'firebase_id = ?',
      whereArgs: [firebaseId],
    );

    if (results.isNotEmpty) {
      return User.fromJson(results.first);
    }

    return null;
  }

  /// Find a user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'user',
      where: 'mail = ?',
      whereArgs: [email],
    );

    if (results.isNotEmpty) {
      return User.fromJson(results.first);
    }

    return null;
  }

  /// Find a user by Google ID
  Future<User?> getUserByGoogleId(String googleId) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'user',
      where: 'google_id = ?',
      whereArgs: [googleId],
    );

    if (results.isNotEmpty) {
      return User.fromJson(results.first);
    }

    return null;
  }

  /// Search for users by email or username
  Future<List<User>> findUsersByEmailOrUsername(String query) async {
    final db = await _databaseHelper.database;

    final results = await db.query(
      'user',
      where: 'mail LIKE ? OR username LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: 10,
    );

    return results.map((map) => User.fromJson(map)).toList();
  }

  /// Create a new user
  Future<int> createUser(User user) async {
    final db = await _databaseHelper.database;

    // Convert the user model to a Map for insertion
    final userData = user.toJson();

    // Remove the id field for auto-increment
    userData.remove('id');

    return await db.insert('user', userData);
  }

  /// Update an existing user
  Future<int> updateUser(User user) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'user',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Get all playlists that a user collaborates on
  Future<List<Map<String, dynamic>>> getUserCollaborativePlaylists(
    int userId,
  ) async {
    final db = await _databaseHelper.database;

    return await db.rawQuery(
      '''
      SELECT p.*, up.role
      FROM playlist p
      JOIN user_playlist up ON p.id = up.playlist_id
      WHERE up.user_id = ?
      ORDER BY p.updated_at DESC
    ''',
      [userId],
    );
  }
}

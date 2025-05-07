import 'package:pos_desktop/db/database_helper.dart';

class Admin {
  final String id;
  final String username;
  final String password;

  Admin({required this.id, required this.username, required this.password});

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'].toString(),
      username: map['username'].toString(),
      password: map['password'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password};
  }

  // Authenticate user by checking credentials from database
  static Future<bool> authenticate(String username, String password) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'admin',
        columns: ['username', 'password'],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final storedUsername = result[0]['username'].toString();
        final storedPassword = result[0]['password'].toString();
        return username == storedUsername && password == storedPassword;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

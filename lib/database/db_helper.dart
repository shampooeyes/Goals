import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DatabaseHelper {
  // static Future<Database> database() async {
  //   final dbPath = await sql.getDatabasesPath();
  //   return sql.openDatabase(path.join(dbPath, "goals.db"),
  //       onCreate: (db, version) {
  //     return db.execute(
  //         "CREATE TABLE Goals(id TEXT PRIMARY KEY, parentId TEXT, title TEXT, desc TEXT, enddate TEXT, reminder INTEGER, repeat INTEGER)");
  //   },version: 1);
  // }

  static Future<void> insertGoal(String table, Map<String, Object> data) async {
    final dbPath = await sql.getDatabasesPath();
    if (table == "Goals") {
      final goalDb = await sql.openDatabase(path.join(dbPath, 'goals.db'),
          onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE Goals(id TEXT PRIMARY KEY, parentId TEXT, title TEXT, desc TEXT, enddate TEXT, reminder INTEGER, repeat INTEGER)');
      }, version: 1);
      goalDb.insert(
        table,
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
    }
    if (table == "Milestones") {
      final milestoneDb = await sql.openDatabase(
          path.join(dbPath, "milestones.db"), onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE Milestones(id TEXT PRIMARY KEY, parentId TEXT, title TEXT, enddate TEXT, reminder INTEGER)");
      }, version: 1);
      int result = await milestoneDb.insert(
        table,
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
      print(result);
    }
  }

  static Future<void> removeGoal(String table, String id) async {
    final bool isGoal = table == "Goals" ? true : false;
    final dbPath = await sql.getDatabasesPath();
    final db = await sql
        .openDatabase(path.join(dbPath, isGoal ? "goals.db" : "milestones.db"));
    final result = await db.delete(table, where: "id = ?", whereArgs: [id]);
    print(result);
  }

  static Future<void> insertHabit(
      String table, Map<String, Object> data) async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(path.join(dbPath, "habits.db"),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE Habits(id TEXT PRIMARY KEY, title TEXT, enddate TEXT, creationDate INTEGER, make INTEGER, repeat INTEGER, reminder INTEGER)");
    }, version: 1);
    db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getHabitsData() async {
    final dbPath = await sql.getDatabasesPath();
    final habitDb = await sql.openDatabase(path.join(dbPath, "habits.db"),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE Habits(id TEXT PRIMARY KEY, title TEXT, enddate TEXT, creationDate INTEGER, make INTEGER, repeat INTEGER, reminder INTEGER)");
    }, version: 1);
    return habitDb.query("Habits");
  }

  static Future<List<Map<String, dynamic>>> getGoalsData() async {
    final dbPath = await sql.getDatabasesPath();
    final goalDb = await sql.openDatabase(path.join(dbPath, "goals.db"),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE Goals(id TEXT PRIMARY KEY, parentId TEXT, title TEXT, desc TEXT, enddate TEXT, reminder INTEGER, repeat INTEGER)");
    }, version: 1);
    return goalDb.query("Goals");
  }

  static Future<List<Map<String, dynamic>>> getMilestonesData() async {
    final dbPath = await sql.getDatabasesPath();
    final milestoneDb = await sql.openDatabase(
        path.join(dbPath, "milestones.db"), onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE Milestones(id TEXT PRIMARY KEY, parentId TEXT, title TEXT, enddate TEXT)");
    }, version: 1);
    return milestoneDb.query("Milestones");
  }
}
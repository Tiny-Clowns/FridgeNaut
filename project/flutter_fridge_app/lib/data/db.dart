import "dart:async";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";
import "package:sqflite/sqflite.dart";

// Local database
class AppDb {
  static Database? _db;
  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, "fridge.db");
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  static Future<void> _onCreate(Database db, int v) async {
    await db.execute("""
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        expirationDate TEXT NULL,
        pricePerUnit REAL NULL,
        toBuy INTEGER NOT NULL,
        notifyOnLow INTEGER NOT NULL,
        notifyOnExpire INTEGER NOT NULL,
        lowThreshold REAL NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      );
    """);

    await db.execute("""
      CREATE TABLE events(
        id TEXT PRIMARY KEY,
        itemId TEXT NOT NULL,
        deltaQuantity REAL NOT NULL,
        unitPriceAtEvent REAL NULL,
        type TEXT NOT NULL,
        occurredAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      );
    """);

    await db.execute("""
      CREATE TABLE meta(
        k TEXT PRIMARY KEY,
        v TEXT NOT NULL
      );
    """);
  }
}

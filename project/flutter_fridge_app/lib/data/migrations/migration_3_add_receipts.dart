// lib/data/migrations/migration_3_add_receipts.dart
import "package:sqflite/sqflite.dart";

Future<void> migration3AddReceipts(Database db) async {
  await db.execute("""
    CREATE TABLE IF NOT EXISTS receipts(
      id TEXT PRIMARY KEY,
      imagePath TEXT NOT NULL,
      ocrText TEXT NOT NULL,
      scannedAt TEXT NOT NULL
    );
  """);
}

// lib/data/migrations/migration_2_add_image_path.dart
import "package:sqflite/sqflite.dart";

Future<void> migration2AddImagePath(Database db) async {
  await db.execute("""
    ALTER TABLE items ADD COLUMN imagePath TEXT NULL;
  """);
}

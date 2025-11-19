// lib/data/migrations/migration_runner.dart
import "package:sqflite/sqflite.dart";

import "migration_2_add_image_path.dart";

class MigrationRunner {
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      switch (v) {
        case 2:
          await migration2AddImagePath(db);
          break;
      }
    }
  }
}

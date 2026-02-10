// lib/data/migrations/migration_runner.dart
import "package:sqflite/sqflite.dart";

import "migration_2_add_image_path.dart";
import "migration_3_add_receipts.dart";

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
        case 3:
          await migration3AddReceipts(db);
          break;
      }
    }
  }
}

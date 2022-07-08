import 'package:cat_calories/database/migrations/abstract_migration.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations.dart';

class MigrationExecutor {
  static final List<AbstractMigration> migrations = [
    V001FirstMigration(),
    V002AddTableProducts(),
  ];

  upgrade(Database db, int oldVersion, int newVersion) async {
    final Batch batch = db.batch();

    if (newVersion == 2) {
      await V002AddTableProducts().up(batch);
    }
  }

  downgrade(Database db, int oldVersion, int newVersion) async {
    final Batch batch = db.batch();

    if (newVersion == 1) {
      await V002AddTableProducts().down(batch);
    }
  }
}

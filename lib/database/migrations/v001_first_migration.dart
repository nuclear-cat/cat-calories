import 'package:cat_calories/database/migrations/abstract_migration.dart';
import 'package:sqflite_common/sqlite_api.dart';

class V001FirstMigration extends AbstractMigration {
  @override
  Future<void> down(Batch batch) async {}

  @override
  Future<void> up(Batch batch) async {}
}

import 'package:cat_calories/database/migrations/abstract_migration.dart';
import 'package:sqflite_common/sqlite_api.dart';

class V002AddTableProducts extends AbstractMigration {
  @override
  Future<void> up(Batch batch) async {
    // batch.execute('''
    //
		// 	''');

    await batch.commit();
  }

  @override
  Future<void> down(Batch batch) async {
    batch.execute('DROP TABLE products');

    await batch.commit();
  }
}

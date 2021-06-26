import 'package:cat_calories/database/migrations/abstract_migration.dart';
import 'package:sqflite_common/sqlite_api.dart';

class V002AddTableProducts extends AbstractMigration {
  @override
  Future<void> up(Batch batch) async {
    batch.execute('''
				CREATE TABLE products(
					id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
					title TEXT,
					description TEXT NULL,
					created_at INT,
					updated_at INT,
					uses_count INT,
					profile_id INT,
					sort_order INT DEFAULT 0,
					barcode INT NULL,
					calorie_content REAL NULL,
					proteins REAL NULL,
					fats REAL NULL,
					carbohydrates REAL NULL,
					
				  FOREIGN KEY(profile_id) REFERENCES profiles(id)
				)
			''');

    await batch.commit();
  }

  @override
  Future<void> down(Batch batch) async {
    batch.execute('DROP TABLE products');

    await batch.commit();
  }
}

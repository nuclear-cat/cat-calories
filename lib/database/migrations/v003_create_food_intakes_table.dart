import 'package:cat_calories/database/migrations/abstract_migration.dart';
import 'package:sqflite_common/sqlite_api.dart';

class V003CreateFoodIntakesTable extends AbstractMigration {
  @override
  Future<Batch> up(Batch batch) async {

    batch.execute('''
    		CREATE TABLE food_intakes (
    			id INTEGER PRIMARY KEY NOT NULL,
          created_at INT,
          eaten_at INT NULL,
          description TEXT NULL,
          reason_comment TEXT NULL,
          comment_after_intake TEXT NULL,
          emotions_after_intake_comment TEXT NULL,
          satiety_level_before_intake INT NULL,
          satiety_level_after_intake INT NULL,
          profile_id INT,
          waking_period_id INT,

          FOREIGN KEY(profile_id) REFERENCES profiles(id),
          FOREIGN KEY(waking_period_id) REFERENCES waking_periods(id)
    		)
    	''');

    batch.execute('''
        ALTER TABLE calorie_items ADD COLUMN food_intake_id INTEGER NULL REFERENCES food_intakes(id)
    ''');

    return batch;
  }

  @override
  Future<Batch> down(Batch batch) async {
    batch.execute('''
				CREATE TABLE calorie_items_new (
					id INTEGER PRIMARY KEY NOT NULL,
					value REAL,
					title TEXT NULL,
					description TEXT NULL,
					sort_order INT,
					created_at INT,
					created_at_day INT,
					eaten_at INT NULL,
					profile_id INT,
					waking_period_id INT,
					FOREIGN KEY(profile_id) REFERENCES profiles(id)
					FOREIGN KEY(waking_period_id) REFERENCES waking_periods(id)
				)
			''');

    batch.execute('''
      INSERT INTO calorie_items_new 
      SELECT 
          id,
					value,
					title,
					description,
					sort_order,
					created_at,
					created_at_day,
					eaten_at,
					profile_id,
					waking_period_id
      FROM calorie_items
      ''');

    batch.execute('DROP TABLE food_intakes');
    batch.execute('DROP TABLE calorie_items');
    batch.execute('ALTER TABLE calorie_items_new RENAME TO calorie_items');

    batch.execute('''
				CREATE INDEX calorie_items_created_at_day_idx ON calorie_items(created_at_day)
			''');

    return batch;
  }

  @override
  int getVersion() {
    return 3;
  }
}

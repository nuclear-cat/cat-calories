import 'package:cat_calories/database.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:sqflite/sqflite.dart';

class CalorieItemRepository {
  Future<List<CalorieItemModel>> findAll() async {
    final calorieItemsResult = await DBProvider.db.query('calorie_items', orderBy: 'sort_order ASC');

    return calorieItemsResult.map((element) => CalorieItemModel.fromJson(element)).toList();
  }

  Future<List<CalorieItemModel>> fetchAllByProfile(ProfileModel profile) async {
    final calorieItemsResult = await DBProvider.db.query('calorie_items', where: 'profile_id = ?', whereArgs: [profile.id]);

    return calorieItemsResult.map((element) => CalorieItemModel.fromJson(element)).toList();
  }

  Future<List<CalorieItemModel>> fetchByCreatedAtDay(DateTime createdAtDay) async {
    final calorieItemsResult = await DBProvider.db.query(
      'calorie_items',
      orderBy: 'sort_order ASC',
      where: 'created_at_day >= ?',
      whereArgs: [DateTime(createdAtDay.year, createdAtDay.month, createdAtDay.day).millisecondsSinceEpoch / 100000],
    );

    return calorieItemsResult.map((element) => CalorieItemModel.fromJson(element)).toList();
  }

  Future<void> deleteByCreatedAtDay(DateTime createdAtDay, ProfileModel profile) async {

    final int dateTimestamp = (DateTime(createdAtDay.year, createdAtDay.month, createdAtDay.day).millisecondsSinceEpoch / 100000).round().toInt();

    await DBProvider.db.delete(
      'calorie_items',
      where: 'created_at_day = ? AND profile_id = ?',
      whereArgs: [dateTimestamp, profile.id],
    );
  }

  Future<List<CalorieItemModel>> fetchByWakingPeriodAndProfile(WakingPeriodModel wakingPeriod, ProfileModel profile) async {
    final calorieItemsResult = await DBProvider.db.query(
      'calorie_items',
      orderBy: 'sort_order ASC',
      where: 'waking_period_id = ? AND profile_id = ?',
      whereArgs: [
        wakingPeriod.id,
        profile.id,
      ],
    );

    return calorieItemsResult.map((element) => CalorieItemModel.fromJson(element)).toList();
  }

  Future<CalorieItemModel?> find(int id) async {
    final calorieItemsResult = await DBProvider.db.query('calorie_items', where: 'id = ?', whereArgs: [id], limit: 1);

    if (calorieItemsResult.length > 0) {
      return CalorieItemModel.fromJson(calorieItemsResult[0]);
    }

    return null;
  }

  Future<List<DayResultModel>> fetchDaysByProfile(ProfileModel profile, int limit) async {
    final result = await DBProvider.db.rawQuery('''
      SELECT 
          SUM(ci.value) as value_sum, 
          ci.created_at_day
      
      FROM calorie_items ci
      WHERE ci.profile_id = ?

      GROUP BY created_at_day
      ORDER BY created_at_day DESC
      
      LIMIT ?
    ''', [profile.id, limit]);

    return result.map((element) => DayResultModel.fromJson(element)).toList();
  }

  Future<CalorieItemModel> insert(CalorieItemModel calorieItem) async {
    calorieItem.id = await DBProvider.db.insert('calorie_items', calorieItem.toJson());

    return calorieItem;
  }

  Future<void> offsetSortOrder() async {
    await DBProvider.db.rawQuery('UPDATE calorie_items SET sort_order = sort_order + 1');
  }

  Future<CalorieItemModel> update(CalorieItemModel calorieItem) async {
    await DBProvider.db.update('calorie_items', calorieItem.toJson(), where: 'id = ?', whereArgs: [calorieItem.id]);

    return calorieItem;
  }

  Future<int> delete(CalorieItemModel calorieItem) async {
    return await DBProvider.db.delete('calorie_items', where: 'id = ?', whereArgs: [calorieItem.id]);
  }

  Future<int> deleteAll() async {
    return await DBProvider.db.delete('calorie_items');
  }

  Future resort(List<CalorieItemModel> items) async {
    Batch batch = await DBProvider.db.batch();

    for (var i = 0; i < items.length; i++) {
      final CalorieItemModel calorieItem = items[i];
      batch.update('calorie_items', {'sort_order': i}, where: 'id = ?', whereArgs: [calorieItem.id]);
    }

    return await batch.commit();
  }
}

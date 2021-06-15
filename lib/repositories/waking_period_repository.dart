import 'package:cat_calories/database.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';

class WakingPeriodRepository {
  Future<List<WakingPeriodModel>> fetchAll() async {
    final wakingPeriodsResult = await DBProvider.db.query('waking_periods');

    return wakingPeriodsResult
        .map((element) => WakingPeriodModel.fromJson(element))
        .toList();
  }

  Future<List<WakingPeriodModel>> fetchByProfile(ProfileModel profile) async {
    final wakingPeriodsResult = await DBProvider.db.query('waking_periods', where: 'profile_id = ?', whereArgs: [profile.id!], orderBy: 'id DESC');

    return wakingPeriodsResult
        .map((element) => WakingPeriodModel.fromJson(element))
        .toList();
  }

  Future<WakingPeriodModel> insert(WakingPeriodModel wakingPeriod) async {
    wakingPeriod.id = await DBProvider.db.insert('waking_periods', wakingPeriod.toJson());

    return wakingPeriod;
  }

  Future<int> delete(WakingPeriodModel wakingPeriod) async {
    return await DBProvider.db
        .delete('waking_periods', where: 'id = ?', whereArgs: [wakingPeriod.id]);
  }

  Future<WakingPeriodModel?> findActual() async {
    final wakingPeriodsResult = await DBProvider.db.rawQuery('SELECT * FROM waking_periods WHERE ended_at IS NULL');

    if (wakingPeriodsResult.toList().length == 0) {
      return null;
    }

    return WakingPeriodModel.fromJson(wakingPeriodsResult.toList().first);
  }

  Future<int> deleteAll() async {
    return await DBProvider.db.delete('waking_periods');
  }

  Future<WakingPeriodModel> update(WakingPeriodModel wakingPeriod) async {
    await DBProvider.db.update('waking_periods', wakingPeriod.toJson(),
        where: 'id = ?', whereArgs: [wakingPeriod.id]);

    return wakingPeriod;
  }
}

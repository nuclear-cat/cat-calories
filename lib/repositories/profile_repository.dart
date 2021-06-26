import 'package:cat_calories/database/database.dart';
import 'package:cat_calories/models/profile_model.dart';

class ProfileRepository {
  Future<List<ProfileModel>> fetchAll() async {
    final profilesResult = await DBProvider.db.query('profiles');

    return profilesResult
        .map((element) => ProfileModel.fromJson(element))
        .toList();
  }

  Future<ProfileModel> insert(ProfileModel profile) async {
    profile.id = await DBProvider.db.insert('profiles', profile.toJson());

    return profile;
  }

  Future<int> delete(ProfileModel profile) async {
    return await DBProvider.db
        .delete('profiles', where: 'id = ?', whereArgs: [profile.id]);
  }

  Future<int> deleteAll() async {
    return await DBProvider.db.delete('profiles');
  }

  Future<ProfileModel> update(ProfileModel profile) async {
    await DBProvider.db.update('profiles', profile.toJson(),
        where: 'id = ?', whereArgs: [profile.id]);

    return profile;
  }
}

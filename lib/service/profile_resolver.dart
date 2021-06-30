import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/repositories/profile_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileResolver {

  final locator = GetIt.instance;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static ProfileModel? _activeProfile;
  late ProfileRepository _profileRepository = locator.get<ProfileRepository>();
  static const String activeProfileKey = 'active_profile';

  Future<ProfileModel> resolve() async {
    SharedPreferences prefs = await _prefs;

    if (_activeProfile == null) {
      final List<ProfileModel> profiles = await _profileRepository.fetchAll();

      final int? activeProfileId = await prefs.getInt(activeProfileKey);

      if (activeProfileId == null) {
        _activeProfile = profiles.length > 0 ? profiles.first : null;
      } else {
        profiles.forEach((ProfileModel profile) {
          if (profile.id == activeProfileId) {
            _activeProfile = profile;
          }
        });
      }
    }

    if (_activeProfile == null) {
      _profileRepository.insert(ProfileModel(
          id: null,
          name: "Default Profile",
          wakingTimeSeconds: 16 * 60 * 60,
          caloriesLimitGoal: 2000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()));

      List<ProfileModel> profiles = await _profileRepository.fetchAll();

      _activeProfile = profiles.first;
    }

    return _activeProfile!;
  }
}
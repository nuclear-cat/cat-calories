import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:cat_calories/repositories/profile_repository.dart';
import 'package:cat_calories/repositories/waking_period_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/repositories/calorie_item_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_event.dart';

class HomeBloc extends Bloc<AbstractHomeEvent, AbstractHomeState> {
  final CalorieItemRepository calorieItemRepository;
  final ProfileRepository _profileRepository;
  final WakingPeriodRepository _wakingPeriodRepository;
  final DateTime nowDateTime = DateTime.now();
  final String activeProfileKey = 'active_profile';

  ProfileModel? _activeProfile;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  HomeBloc(this.calorieItemRepository, this._profileRepository, this._wakingPeriodRepository) : super(HomeFetchingInProgress());

  _saveActiveProfile(ProfileModel profile) async {
    SharedPreferences prefs = await _prefs;

    prefs.setInt(activeProfileKey, profile.id!);
  }

  Future<void> _setActiveProfile() async {
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

    _saveActiveProfile(_activeProfile!);
  }

  @override
  Stream<AbstractHomeState> mapEventToState(event) async* {
    await _setActiveProfile();

    if (event is CalorieItemListFetchingInProgressEvent) {
      yield* _fetchItems();
    } else if (event is CalorieItemListCreatingEvent) {
      await calorieItemRepository.offsetSortOrder();
      await calorieItemRepository.insert(event.calorieItem);
      event.callback();

      yield* _fetchItems();
    } else if (event is CalorieItemRemovingEvent) {
      await calorieItemRepository.delete(event.calorieItem);
      event.callback();

      yield* _fetchItems();
    } else if (event is CalorieItemListResortingEvent) {
      await calorieItemRepository.resort(event.items);

      yield* _fetchItems();
    } else if (event is CalorieItemListUpdatingEvent) {
      await calorieItemRepository.update(event.calorieItem);

      yield* _fetchItems();
    } else if (event is ProfileCreatingEvent) {
      await _profileRepository.insert(event.profile);

      yield* _fetchItems();
    } else if (event is ProfileUpdatingEvent) {
      await _profileRepository.update(event.profile);

      yield* _fetchItems();
    } else if (event is ProfileChangingEvent) {
      _activeProfile = event.profile;
      _saveActiveProfile(event.profile);

      yield* _fetchItems();
    } else if (event is WakingPeriodCreatingEvent) {
      await _wakingPeriodRepository.insert(event.wakingPeriod);

      yield* _fetchItems();
    } else if (event is WakingPeriodEndingEvent) {
      final WakingPeriodModel wakingPeriod = event.wakingPeriod;

      wakingPeriod.updatedAt = DateTime.now();
      wakingPeriod.endedAt = DateTime.now();
      wakingPeriod.caloriesValue = event.caloriesValue;

      await _wakingPeriodRepository.update(event.wakingPeriod);

      yield* _fetchItems();
    } else if (event is WakingPeriodDeletingEvent) {
      await _wakingPeriodRepository.delete(event.wakingPeriod);

      yield* _fetchItems();
    } else if (event is WakingPeriodUpdatingEvent) {
      await _wakingPeriodRepository.update(event.wakingPeriod);

      yield* _fetchItems();
    } else if (event is RemovingCaloriesByCreatedAtDayEvent) {
      await calorieItemRepository.deleteByCreatedAtDay(event.date, event.profile);

      yield* _fetchItems();

      // Calorie item eat
    } else if (event is CalorieItemEatingEvent) {
      final CalorieItemModel calorieItem = event.calorieItem;
      calorieItem.eatenAt = calorieItem.isEaten() ? null : DateTime.now();

      await calorieItemRepository.update(calorieItem);

      yield* _fetchItems();
      // Delete profile
    } else if (event is ProfileDeletingEvent) {
      yield* _deleteProfile(event.profile);
    }
  }

  Stream<HomeFetched> _deleteProfile(ProfileModel profile) async* {
    final List<ProfileModel> profiles = await _profileRepository.fetchAll();

    if (profiles.length > 1) {
      await _profileRepository.delete(profile);
    }

    _activeProfile = profiles.first;

    yield* _fetchItems();
  }

  Stream<HomeFetched> _fetchItems() async* {
    final ProfileModel activeProfile = _activeProfile!;

    final List<DayResultModel> _dayResultsList = await calorieItemRepository.fetchDaysByProfile(activeProfile, 30);
    final List<ProfileModel> _profiles = await _profileRepository.fetchAll();
    final List<WakingPeriodModel> wakingPeriods = await _wakingPeriodRepository.fetchByProfile(activeProfile);
    final WakingPeriodModel? currentWakingPeriod = await _wakingPeriodRepository.findActual(activeProfile);
    final DateTime startDate = DateTime(nowDateTime.year, nowDateTime.month, nowDateTime.day);
    final DateTime endDate = DateTime(nowDateTime.year, nowDateTime.month, nowDateTime.day).add(Duration(days: 1));
    List<CalorieItemModel> _calorieItems = [];

    if (currentWakingPeriod != null) {
      _calorieItems = await calorieItemRepository.fetchByWakingPeriodAndProfile(currentWakingPeriod, activeProfile);
    }

    yield HomeFetched(
      nowDateTime: DateTime.now(),
      calorieItems: _calorieItems,
      dayResults: _dayResultsList,
      profiles: _profiles,
      wakingPeriods: wakingPeriods,
      activeProfile: activeProfile,
      startDate: startDate,
      endDate: endDate,
      currentWakingPeriod: currentWakingPeriod,
    );
  }
}

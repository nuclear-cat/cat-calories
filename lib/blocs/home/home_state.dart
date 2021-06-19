import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';

abstract class AbstractHomeState {}

class HomeFetchingInProgress extends AbstractHomeState {}

class HomeFetched extends AbstractHomeState {
  final DateTime nowDateTime;
  final List<CalorieItemModel> calorieItems;
  final List<DayResultModel> dayResults;
  final List<ProfileModel> profiles;
  final List<WakingPeriodModel> wakingPeriods;
  final ProfileModel activeProfile;
  final DateTime startDate;
  final DateTime endDate;
  final WakingPeriodModel? currentWakingPeriod;

  HomeFetched({
    required this.nowDateTime,
    required this.calorieItems,
    required this.dayResults,
    required this.profiles,
    required this.wakingPeriods,
    required this.activeProfile,
    required this.startDate,
    required this.endDate,
    required this.currentWakingPeriod,
  });

  double getPeriodCaloriesEatenSum() {
    double totalCalories = 0;

    calorieItems.forEach((CalorieItemModel calorieItem) {
      if (calorieItem.isEaten()) {
        totalCalories += calorieItem.value;
      }
    });

    return totalCalories;
  }
}

import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';

abstract class AbstractHomeState {}

class HomeFetchingInProgress extends AbstractHomeState {}

class HomeFetched extends AbstractHomeState {
  final DateTime nowDateTime;
  final List<CalorieItemModel> periodCalorieItems;
  final List<CalorieItemModel> todayCalorieItems;
  final List<DayResultModel> days;
  final List<ProfileModel> profiles;
  final List<WakingPeriodModel> wakingPeriods;
  final ProfileModel activeProfile;
  final DateTime startDate;
  final DateTime endDate;
  final WakingPeriodModel? currentWakingPeriod;
  final double preparedCaloriesValue;

  HomeFetched({
    required this.nowDateTime,
    required this.periodCalorieItems,
    required this.todayCalorieItems,
    required this.days,
    required this.profiles,
    required this.wakingPeriods,
    required this.activeProfile,
    required this.startDate,
    required this.endDate,
    required this.currentWakingPeriod,
    required this.preparedCaloriesValue,
  });

  double getPeriodCaloriesEatenSum() {
    double totalCalories = 0;

    periodCalorieItems.forEach((CalorieItemModel calorieItem) {
      if (calorieItem.isEaten()) {
        totalCalories += calorieItem.value;
      }
    });

    totalCalories += preparedCaloriesValue;

    return totalCalories;
  }

  double getTodayCaloriesEatenSum() {
    double totalCalories = 0;

    todayCalorieItems.forEach((CalorieItemModel calorieItem) {
      if (calorieItem.isEaten()) {
        totalCalories += calorieItem.value;
      }
    });

    totalCalories += preparedCaloriesValue;

    return totalCalories;
  }

  DateTime getDayStart() {
    return DateTime(nowDateTime.year, nowDateTime.month, nowDateTime.day, 0, 0, 0);
  }

  List<DayResultModel> getDaysUntilToday() {
    List<DayResultModel> days = [];

    this.days.forEach((DayResultModel dayResult) {
      if (getDayStart().millisecondsSinceEpoch > dayResult.createdAtDay.millisecondsSinceEpoch) {
        days.add(dayResult);
      }
    });

    return days;
  }
}

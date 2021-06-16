import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';

abstract class AbstractHomeEvent {}

class CalorieItemListFetchingInProgressEvent extends AbstractHomeEvent {}

class HomeFetchedEvent extends AbstractHomeEvent {}

class CalorieItemListCreatingEvent extends AbstractHomeEvent {
  final CalorieItemModel calorieItem;
  final List<CalorieItemModel> calorieItems;
  final callback;

  CalorieItemListCreatingEvent(this.calorieItem, this.calorieItems, this.callback);
}

class ProfileChangingEvent extends AbstractHomeEvent {
  final ProfileModel profile;
  final dynamic callback;

  ProfileChangingEvent(this.profile, this.callback);
}

class CalorieItemRemovingEvent extends AbstractHomeEvent {
  final CalorieItemModel calorieItem;
  final List<CalorieItemModel> calorieItems;
  final callback;

  CalorieItemRemovingEvent(this.calorieItem, this.calorieItems, this.callback);
}

class CalorieItemListUpdatingEvent extends AbstractHomeEvent {
  final CalorieItemModel calorieItem;
  final List<CalorieItemModel> calorieItems;
  final callback;

  CalorieItemListUpdatingEvent(this.calorieItem, this.calorieItems, this.callback);
}

class CalorieItemListResortingEvent extends AbstractHomeEvent {
  CalorieItemListResortingEvent(this.items);

  final List<CalorieItemModel> items;
}

class ProfileCreatingEvent extends AbstractHomeEvent {
  ProfileModel profile;
  final callback;

  ProfileCreatingEvent(this.profile, this.callback);
}

class ProfileUpdatingEvent extends AbstractHomeEvent {
  ProfileModel profile;

  ProfileUpdatingEvent(this.profile);
}

class WakingPeriodCreatingEvent extends AbstractHomeEvent {
  final WakingPeriodModel wakingPeriod;

  WakingPeriodCreatingEvent(this.wakingPeriod);
}

class WakingPeriodEndingEvent extends AbstractHomeEvent {
  final WakingPeriodModel wakingPeriod;
  final double caloriesValue;

  WakingPeriodEndingEvent(this.wakingPeriod, this.caloriesValue);
}

class WakingPeriodDeletingEvent extends AbstractHomeEvent {
  final WakingPeriodModel wakingPeriod;

  WakingPeriodDeletingEvent(this.wakingPeriod);
}

class WakingPeriodUpdatingEvent extends AbstractHomeEvent {
  final WakingPeriodModel wakingPeriod;

  WakingPeriodUpdatingEvent(this.wakingPeriod);
}

class RemovingDayCaloriesEvent extends AbstractHomeEvent {
  final DateTime date;

  RemovingDayCaloriesEvent(this.date);
}
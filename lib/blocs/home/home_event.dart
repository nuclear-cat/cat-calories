import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';

abstract class AbstractHomeEvent {}

class CalorieItemListFetchingInProgressEvent extends AbstractHomeEvent {}

class HomeFetchedEvent extends AbstractHomeEvent {}

class CreatingCalorieItemEvent extends AbstractHomeEvent {
  String expression;
  List<CalorieItemModel> calorieItems;
  WakingPeriodModel wakingPeriod;
  final void Function(CalorieItemModel) callback;

  CreatingCalorieItemEvent(
    this.expression,
    this.wakingPeriod,
    this.calorieItems,
    this.callback,
  );
}

class ChangingProfileEvent extends AbstractHomeEvent {
  final ProfileModel profile;
  final dynamic callback;

  ChangingProfileEvent(this.profile, this.callback);
}

class RemovingCalorieItemEvent extends AbstractHomeEvent {
  final CalorieItemModel calorieItem;
  final List<CalorieItemModel> calorieItems;
  final callback;

  RemovingCalorieItemEvent(this.calorieItem, this.calorieItems, this.callback);
}

class CalorieItemEatingEvent extends AbstractHomeEvent {
  final CalorieItemModel calorieItem;

  CalorieItemEatingEvent(this.calorieItem);
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

class ProfileDeletingEvent extends AbstractHomeEvent {
  ProfileModel profile;

  ProfileDeletingEvent(this.profile);
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

class RemovingCaloriesByCreatedAtDayEvent extends AbstractHomeEvent {
  final DateTime date;
  final ProfileModel profile;

  RemovingCaloriesByCreatedAtDayEvent(this.date, this.profile);
}

class CaloriePreparedEvent extends AbstractHomeEvent {
  final String expression;

  CaloriePreparedEvent(this.expression);
}

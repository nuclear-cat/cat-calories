import 'package:cat_calories/models/profile_model.dart';

abstract class AbstractCaloriesEvent {}

class CaloriesFetchProgressEvent extends AbstractCaloriesEvent {
  final ProfileModel profile;
  final DateTime dayStart;
  final invertSortOrder;

  CaloriesFetchProgressEvent(this.profile, this.dayStart, this.invertSortOrder);
}

class CaloriesFetchedEvent extends AbstractCaloriesEvent {
  final ProfileModel profile;

  CaloriesFetchedEvent(this.profile);
}

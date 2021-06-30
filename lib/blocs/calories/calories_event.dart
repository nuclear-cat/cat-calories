import 'package:cat_calories/models/profile_model.dart';

abstract class AbstractCaloriesEvent {}

class CaloriesFetchProgressEvent extends AbstractCaloriesEvent {
  final ProfileModel profile;

  CaloriesFetchProgressEvent(this.profile);
}

class CaloriesFetchedEvent extends AbstractCaloriesEvent {
  final ProfileModel profile;

  CaloriesFetchedEvent(this.profile);
}

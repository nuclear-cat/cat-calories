import 'package:cat_calories/models/calorie_item_model.dart';

abstract class AbstractCaloriesState {}

class CaloriesFetchProgressState extends AbstractCaloriesState {}

class CaloriesFetchedState extends AbstractCaloriesState {
  final List<CalorieItemModel> calorieItems;

  CaloriesFetchedState(this.calorieItems);
}

import 'package:cat_calories/models/calorie_item_model.dart';

abstract class AbstractCaloriesState {}

class CaloriesFetchInProgressState extends AbstractCaloriesState {}

class CaloriesFetchSuccessState extends AbstractCaloriesState {
  final Iterable<CalorieItemModel> calorieItems;

  CaloriesFetchSuccessState(this.calorieItems);
}

import 'package:cat_calories/blocs/calories/calories_event.dart';
import 'package:cat_calories/blocs/calories/calories_state.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/repositories/calorie_item_repository.dart';
import 'package:cat_calories/service/profile_resolver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class CaloriesBloc extends Bloc<AbstractCaloriesEvent, AbstractCaloriesState> {
  final locator = GetIt.instance;
  ProfileModel? _activeProfile;

  late CalorieItemRepository calorieItemRepository =
      locator.get<CalorieItemRepository>();

  CaloriesBloc() : super(CaloriesFetchProgressState());

  @override
  Stream<AbstractCaloriesState> mapEventToState(event) async* {
    if (_activeProfile == null) {
      _activeProfile = await ProfileResolver().resolve();
    }

    if (event is CaloriesFetchProgressEvent) {
      yield* _fetchData(event.invertSortOrder, event.dayStart);
    }
  }

  Stream<CaloriesFetchedState> _fetchData(
      bool invertSortOrder, DateTime dayStart) async* {
    final calorieItems = await calorieItemRepository.fetchAllByProfileAndDay(
        _activeProfile!,
        orderBy: 'created_at ' + (invertSortOrder ? 'ASC' : 'DESC'),
        limit: 50,
        dayStart: dayStart);

    yield CaloriesFetchedState(calorieItems);
  }
}

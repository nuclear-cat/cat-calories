import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/models/product_model.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:cat_calories/repositories/product_repository.dart';
import 'package:cat_calories/repositories/profile_repository.dart';
import 'package:cat_calories/repositories/waking_period_repository.dart';
import 'package:cat_calories/service/profile_resolver.dart';
import 'package:cat_calories/utils/expression_executor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/repositories/calorie_item_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_event.dart';

class HomeBloc extends Bloc<AbstractHomeEvent, AbstractHomeState> {
  final locator = GetIt.instance;

  final DateTime nowDateTime = DateTime.now();

  late ProductRepository productRepository = locator.get<ProductRepository>();
  late CalorieItemRepository calorieItemRepository =
      locator.get<CalorieItemRepository>();
  late ProfileRepository profileRepository = locator.get<ProfileRepository>();
  late WakingPeriodRepository wakingPeriodRepository =
      locator.get<WakingPeriodRepository>();

  ProfileModel? _activeProfile;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  double _preparedCaloriesValue = 0;

  HomeBloc() : super(HomeFetchingInProgress());

  _saveActiveProfile(ProfileModel profile) async {
    SharedPreferences prefs = await _prefs;

    prefs.setInt(ProfileResolver.activeProfileKey, profile.id!);
  }

  @override
  Stream<AbstractHomeState> mapEventToState(event) async* {
    if (_activeProfile == null) {
      _activeProfile = await ProfileResolver().resolve();
    }

    if (event is CalorieItemListFetchingInProgressEvent) {
      yield* _fetchHomeData();
    } else if (event is CreatingCalorieItemEvent) {
      final CalorieItemModel calorieItem = CalorieItemModel(
          id: null,
          value: _preparedCaloriesValue,
          sortOrder: 0,
          eatenAt: DateTime.now(),
          createdAt: DateTime.now(),
          description: null,
          profileId: _activeProfile!.id!,
          wakingPeriodId: event.wakingPeriod.id!);

      await calorieItemRepository.offsetSortOrder();
      await calorieItemRepository.insert(calorieItem);
      _preparedCaloriesValue = 0;

      event.callback(calorieItem);

      yield* _fetchHomeData();
    } else if (event is RemovingCalorieItemEvent) {
      await calorieItemRepository.delete(event.calorieItem);
      event.callback();

      yield* _fetchHomeData();
    } else if (event is CalorieItemListResortingEvent) {
      await calorieItemRepository.resort(event.items);

      yield* _fetchHomeData();
    } else if (event is CalorieItemListUpdatingEvent) {
      await calorieItemRepository.update(event.calorieItem);

      yield* _fetchHomeData();
    } else if (event is ProfileCreatingEvent) {
      await profileRepository.insert(event.profile);

      yield* _fetchHomeData();
    } else if (event is ProfileUpdatingEvent) {
      await profileRepository.update(event.profile);

      yield* _fetchHomeData();
    } else if (event is ChangeProfileEvent) {
      _activeProfile = event.profile;
      _saveActiveProfile(event.profile);

      yield* _fetchHomeData();
    } else if (event is WakingPeriodCreatingEvent) {
      await wakingPeriodRepository.insert(event.wakingPeriod);

      yield* _fetchHomeData();
    } else if (event is WakingPeriodEndingEvent) {
      final WakingPeriodModel wakingPeriod = event.wakingPeriod;

      wakingPeriod.updatedAt = DateTime.now();
      wakingPeriod.endedAt = DateTime.now();
      wakingPeriod.caloriesValue = event.caloriesValue;

      await wakingPeriodRepository.update(event.wakingPeriod);

      yield* _fetchHomeData();
    } else if (event is WakingPeriodDeletingEvent) {
      await wakingPeriodRepository.delete(event.wakingPeriod);

      yield* _fetchHomeData();
    } else if (event is WakingPeriodUpdatingEvent) {
      await wakingPeriodRepository.update(event.wakingPeriod);

      yield* _fetchHomeData();
    } else if (event is RemovingCaloriesByCreatedAtDayEvent) {
      await calorieItemRepository.deleteByCreatedAtDay(
          event.date, event.profile);

      yield* _fetchHomeData();
    } else if (event is CalorieItemEatingEvent) {
      final CalorieItemModel calorieItem = event.calorieItem;
      calorieItem.eatenAt = calorieItem.isEaten() ? null : DateTime.now();

      await calorieItemRepository.update(calorieItem);

      yield* _fetchHomeData();
      // Delete profile
    } else if (event is ProfileDeletingEvent) {
      yield* _deleteProfile(event.profile);
    } else if (event is CaloriePreparedEvent) {
      _preparedCaloriesValue = ExpressionExecutor.execute(event.expression);

      yield* _fetchHomeData();
    } else if (event is CreateProductEvent) {
      await _createProduct(event);

      yield* _fetchHomeData();
    } else if (event is DeleteProductEvent) {
      await productRepository.delete(event.product);

      yield* _fetchHomeData();
    } else if (event is UpdateProductEvent) {
      await productRepository.update(event.product);

      yield* _fetchHomeData();
    } else if (event is EatProductEvent) {
      _eatProduct(event);

      yield* _fetchHomeData();
    } else if (event is ProductsResortEvent) {
      await productRepository.resort(event.products);

      yield* _fetchHomeData();
    }
  }

  Future<void> _eatProduct(EatProductEvent event) async {
    final CalorieItemModel calorieItem = CalorieItemModel(
      id: null,
      value: (event.product.calorieContent! / 100) *
          ExpressionExecutor.execute(event.expression),
      sortOrder: 0,
      eatenAt: DateTime.now(),
      createdAt: DateTime.now(),
      description: event.product.title,
      profileId: _activeProfile!.id!,
      wakingPeriodId: event.wakingPeriod.id!,
    );

    event.product.usesCount = event.product.usesCount + 1;

    await calorieItemRepository.offsetSortOrder();
    await calorieItemRepository.insert(calorieItem);
    await productRepository.update(event.product);

    event.callback(calorieItem);
  }

  Future<void> _createProduct(CreateProductEvent event) async {
    final product = ProductModel(
      id: null,
      title: event.title,
      description: event.description,
      usesCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      profileId: _activeProfile!.id!,
      barcode: event.barcode,
      calorieContent: event.calorieContent,
      proteins: event.proteins,
      fats: event.fats,
      carbohydrates: event.carbohydrates,
      sortOrder: 0,
    );

    await productRepository.insert(product);
  }

  Stream<HomeFetched> _deleteProfile(ProfileModel profile) async* {
    final List<ProfileModel> profiles = await profileRepository.fetchAll();

    if (profiles.length > 1) {
      await profileRepository.delete(profile);
    }

    _activeProfile = profiles.first;

    yield* _fetchHomeData();
  }

  Stream<HomeFetched> _fetchHomeData() async* {
    final ProfileModel activeProfile = _activeProfile!;

    final List<DayResultModel> _dayResultsList30days =
        await calorieItemRepository.fetchDaysByProfile(activeProfile, 30);


    final List<DayResultModel> _dayResultsList2days =
        await calorieItemRepository.fetchDaysByProfile(activeProfile, 2);



    final List<ProfileModel> _profiles = await profileRepository.fetchAll();
    final List<WakingPeriodModel> wakingPeriods =
        await wakingPeriodRepository.fetchByProfile(activeProfile);
    final List<ProductModel> products = await productRepository.fetchAll();

    final WakingPeriodModel? currentWakingPeriod =
        await wakingPeriodRepository.findActual(activeProfile);
    final DateTime startDate =
        DateTime(nowDateTime.year, nowDateTime.month, nowDateTime.day);
    final DateTime endDate =
        DateTime(nowDateTime.year, nowDateTime.month, nowDateTime.day)
            .add(Duration(days: 1));

    List<CalorieItemModel> _calorieItems = [];

    if (currentWakingPeriod != null) {
      _calorieItems = await calorieItemRepository.fetchByWakingPeriodAndProfile(
          currentWakingPeriod, activeProfile);
    }

    final List<CalorieItemModel> todayCalorieItems =
        await calorieItemRepository.fetchByCreatedAtDay(nowDateTime);

    yield HomeFetched(
      nowDateTime: DateTime.now(),
      periodCalorieItems: _calorieItems,
      todayCalorieItems: todayCalorieItems,
      days30: _dayResultsList30days,
      days2: _dayResultsList2days,
      profiles: _profiles,
      wakingPeriods: wakingPeriods,
      activeProfile: activeProfile,
      startDate: startDate,
      endDate: endDate,
      currentWakingPeriod: currentWakingPeriod,
      preparedCaloriesValue: _preparedCaloriesValue,
      products: products,
    );
  }
}

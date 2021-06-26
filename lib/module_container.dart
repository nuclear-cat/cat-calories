import 'package:cat_calories/repositories/calorie_item_repository.dart';
import 'package:cat_calories/repositories/product_repository.dart';
import 'package:cat_calories/repositories/profile_repository.dart';
import 'package:cat_calories/repositories/waking_period_repository.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

class ModuleContainer {
  Injector initialise(Injector injector) {
    injector.map((injector, { isSingleton: true, }) => CalorieItemRepository());
    injector.map((injector, { isSingleton: true, }) => ProfileRepository());
    injector.map((injector, { isSingleton: true, }) => WakingPeriodRepository());
    injector.map((injector, { isSingleton: true, }) => ProductRepository());

    return injector;
  }
}
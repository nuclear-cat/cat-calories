import 'package:cat_calories/repositories/profile_repository.dart';
import 'package:cat_calories/repositories/waking_period_repository.dart';
import 'package:cat_calories/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/repositories/calorie_item_repository.dart';
import 'package:cat_calories/screens/home/home_screen.dart';
import 'package:cat_calories/simple_bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              HomeBloc(CalorieItemRepository(), ProfileRepository(), WakingPeriodRepository()),
        ),
      ],
      child: MaterialApp(
        theme: CustomTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        title: 'Cat Calories',
        home: HomeScreen(),
      ),
    );
  }
}

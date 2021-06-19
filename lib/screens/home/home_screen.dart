import 'dart:async';

import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:cat_calories/screens/home/_app_drawer.dart';
import 'package:cat_calories/screens/home/_calorie_items_view.dart';
import 'package:cat_calories/screens/home/_days_view.dart';
import 'package:cat_calories/screens/home/_waking_periods_view.dart';
import 'package:cat_calories/ui/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_event.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/ui/widgets/caclulator_widget.dart';
import 'package:math_expressions/math_expressions.dart';

import '_main_info_view.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<CalorieItemModel> _calorieItems = [];
  TextEditingController _calorieItemController = TextEditingController();
  double _calorieItemPreparedSum = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calorieItemController = TextEditingController();

    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      setState(() {
      });
    });

    _calorieItemController.addListener(() {
      setState(() {
        try {
          Expression exp = Parser().parse(_calorieItemController.text);
          _calorieItemPreparedSum = exp.evaluate(EvaluationType.REAL, ContextModel());
        } catch (e) {
          _calorieItemPreparedSum = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _calorieItemController.dispose();

    if (_timer != null) {
      _timer!.cancel();
    }

    super.dispose();
  }

  _HomeScreenState();

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<HomeBloc>(context).add(CalorieItemListFetchingInProgressEvent());

    void _createCalorieItem(
        double value, ProfileModel profile, List<CalorieItemModel> calorieItems, WakingPeriodModel wakingPeriodModel) {
      final int profileId = profile.id!;

      final CalorieItemModel calorieItem = CalorieItemModel(
          id: null,
          value: value,
          sortOrder: 0,
          eatenAt: null,
          createdAt: DateTime.now(),
          description: null,
          profileId: profileId,
          wakingPeriodId: wakingPeriodModel.id!);

      BlocProvider.of<HomeBloc>(context).add(CalorieItemListCreatingEvent(calorieItem, calorieItems, () {
        final snackBar = SnackBar(content: Text('Item added'));
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _calorieItemController.text = '';
      }));
    }

    return Scaffold(
      body: Scaffold(
        body: DefaultTabController(
          length: 4,
          child: Scaffold(
            drawer: Drawer(
              child: AppDrawer(),
            ),
            appBar: AppBar(
              bottom: TabBar(
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                labelPadding: EdgeInsets.zero,
                tabs: [
                  Tab(
                    text: 'Info',
                  ),
                  Tab(
                    text: 'kCal',
                  ),
                  Tab(
                    // icon: Icon(Icons.access_time),
                    text: 'Waking periods',
                  ),
                  Tab(
                    text: 'Days',
                  ),
                ],
              ),

              // Home Screen
              title: BlocBuilder<HomeBloc, AbstractHomeState>(
                builder: (context, state) {
                  if (state is HomeFetched) {
                    if (state.currentWakingPeriod is WakingPeriodModel) {
                      return Text(
                        '${state.getPeriodCaloriesEatenSum().round()} / ${state.currentWakingPeriod!.caloriesLimitGoal} kCal',
                        style: TextStyle(
                          fontSize: 16,
                          color: (state.getPeriodCaloriesEatenSum() > state.currentWakingPeriod!.caloriesLimitGoal
                              ? DangerColor
                              : SuccessColor),
                        ),
                      );
                    }

                    return Text('For current period: ${state.getPeriodCaloriesEatenSum().round()} kCal',
                        style: TextStyle(fontSize: 16));
                  }
                  return Text('...', style: TextStyle(fontSize: 16));
                },
              ),
            ),
            body: TabBarView(
              children: [
                MainInfoView(),
                CalorieItemsView(),
                WakingPeriodsView(),
                DaysView(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<HomeBloc, AbstractHomeState>(builder: (context, state) {
        if (state is HomeFetched && state.currentWakingPeriod != null) {
          return FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet<dynamic>(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  final double totalCaloriesNew = _calorieItemPreparedSum.toDouble() + state.getPeriodCaloriesEatenSum();
                  return FractionallySizedBox(
                    child: Wrap(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.0),
                          decoration: new BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius:
                                  BorderRadius.only(topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                            Text('= ${totalCaloriesNew.toStringAsFixed(2)} kCal', textAlign: TextAlign.center),
                          ]),
                        ),
                        Builder(
                          builder: (context) => Form(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  color: Color(0xFFEEEEEE),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      fillColor: SuccessColor,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                      suffix: Text('kCal'),
                                      prefix: Text('+'),
                                    ),
                                    validator: (value) {
                                      // if (value.isEmpty) {
                                      //   return 'Please enter some value';
                                      // }
                                      return null;
                                    },
                                    maxLines: 1,
                                    controller: _calorieItemController,
                                  ),
                                ),
                                CalculatorWidget(
                                  controller: _calorieItemController,
                                  onPressed: () {
                                    _createCalorieItem(
                                        _calorieItemPreparedSum, state.activeProfile, _calorieItems, state.currentWakingPeriod!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
        return FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).disabledColor,
        );
      }),
    );
  }
}
import 'dart:async';

import 'package:cat_calories/models/waking_period_model.dart';
import 'package:cat_calories/screens/create_product_screen.dart';
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

import '_main_info_view.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<CalorieItemModel> _calorieItems = [];
  TextEditingController _calorieItemController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calorieItemController = TextEditingController();

    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      setState(() {});
    });

    _calorieItemController.addListener(() {
      print(_calorieItemController.text);
      BlocProvider.of<HomeBloc>(context).add(CaloriePreparedEvent(_calorieItemController.text));
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

    void _createCalorieItem(List<CalorieItemModel> calorieItems, WakingPeriodModel wakingPeriod) {
      final String expression = _calorieItemController.text;

      if (expression.length == 0) {
        return;
      }

      BlocProvider.of<HomeBloc>(context)
          .add(CreatingCalorieItemEvent(expression, wakingPeriod, calorieItems, (CalorieItemModel calorieItem) {
        final snackBar = SnackBar(content: Text('${calorieItem.value.toStringAsFixed(2)} kcal added'));
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
              actions: [
                PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'products',
                        child: Text('Products'),
                      ),
                      PopupMenuItem<String>(
                        value: 'create_product',
                        child: Text('Create product'),
                      ),
                    ];
                  },
                  onSelected: (String value) {
                    if (value == 'create_product') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateProductScreen()),
                      );
                    }
                  },
                ),
              ],
              bottom: TabBar(
                isScrollable: true,

                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                // labelPadding: EdgeInsets.zero,
                tabs: [
                  Tab(
                    text: 'Info',
                  ),
                  Tab(
                    text: 'kCal',
                  ),
                  Tab(
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
                barrierColor: Colors.black.withOpacity(0.2),
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (BuildContext context, StateSetter stateSetter) {
                    return FractionallySizedBox(
                      child: Wrap(
                        children: <Widget>[
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
                                      _createCalorieItem(_calorieItems, state.currentWakingPeriod!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  });
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

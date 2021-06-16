import 'dart:async';

import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:cat_calories/screens/create_profile_screen.dart';
import 'package:cat_calories/screens/edit_calorie_item_screen.dart';
import 'package:cat_calories/screens/edit_profile_screen.dart';
import 'package:cat_calories/screens/edit_waking_period_screen.dart';
import 'package:cat_calories/screens/home/waking_period_info.dart';
import 'package:cat_calories/utils/cat_avatar_resolver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_event.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/ui/widgets/caclulator_widget.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<CalorieItemModel> _calorieItems = [];
  TextEditingController _calorieItemController = TextEditingController();
  double _calorieItemPreparedSum = 0;
  DateTime _currentDateTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calorieItemController = TextEditingController();

    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      setState(() {
        _currentDateTime = DateTime.now();
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

    void _removeCalorieItem(CalorieItemModel calorieItem, List<CalorieItemModel> calorieItems) {
      BlocProvider.of<HomeBloc>(context).add(CalorieItemRemovingEvent(calorieItem, calorieItems, () {
        final snackBar = SnackBar(content: Text('Item removed'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }));
    }

    void _removeWakingPeriod(WakingPeriodModel wakingPeriod) {
      BlocProvider.of<HomeBloc>(context).add(WakingPeriodDeletingEvent(wakingPeriod));

      final snackBar = SnackBar(content: Text('Item removed'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      body: Scaffold(
        body: DefaultTabController(
          length: 4,
          child: Scaffold(
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  BlocBuilder<HomeBloc, AbstractHomeState>(
                    builder: (context, state) {
                      if (state is HomeFetched) {
                        return UserAccountsDrawerHeader(
                          accountName: Text(state.activeProfile.name),
                          accountEmail: Text('Goal: ' + state.activeProfile.caloriesLimitGoal.toString() + ' kcal  / day'),
                          currentAccountPicture: CircleAvatar(
                            backgroundImage: CatAvatarResolver.getImageByProfle(state.activeProfile),
                          ),
                        );
                      }

                      return Text('...');
                    },
                  ),
                  BlocBuilder<HomeBloc, AbstractHomeState>(
                    builder: (context, state) {
                      if (state is HomeFetched) {
                        return Column(
                          children: state.profiles.map((ProfileModel profile) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: CatAvatarResolver.getImageByProfle(state.activeProfile),
                              ),
                              title: Text(profile.name),
                              onTap: () {
                                BlocProvider.of<HomeBloc>(context).add(ProfileChangingEvent(profile, {}));
                              },
                            );
                          }).toList(),
                        );
                      }

                      return ListTile(
                        title: Text('...'),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Create profile'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateProfileScreen()));
                      // Navigator.pop(context);
                    },
                  ),
                  Divider(),
                  BlocBuilder<HomeBloc, AbstractHomeState>(
                    builder: (context, state) {
                      if (state is HomeFetched) {
                        return ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Profile settings'),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => EditProfileScreen(state.activeProfile)));
                          },
                        );
                      }
                      return ListTile();
                    },
                  ),
                ],
              ),
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
                      return Text('${state.getTodayCaloriesSum().round()} / ${state.currentWakingPeriod!.caloriesLimitGoal} kCal',
                          style: TextStyle(
                              fontSize: 16,
                              color: (state.getTodayCaloriesSum() > state.currentWakingPeriod!.caloriesLimitGoal
                                  ? Colors.red
                                  : Colors.blue)));
                    }

                    return Text('For current period: ${state.getTodayCaloriesSum().round()} kCal',
                        style: TextStyle(fontSize: 16));
                  }
                  return Text('...', style: TextStyle(fontSize: 16));
                },
              ),
            ),
            body: TabBarView(
              children: [
                BlocBuilder<HomeBloc, AbstractHomeState>(builder: (context, state) {
                  if (state is HomeFetchingInProgress) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is HomeFetched) {
                    return ListView(
                      padding: EdgeInsetsDirectional.all(10),
                      children: [
                        SizedBox(
                          child: WakingPeriodInfo(
                            wakingPeriod: state.currentWakingPeriod,
                            caloriesLimitGoal: 2000,
                            totalCalories: state.getTodayCaloriesSum(),
                            currentDateTime: _currentDateTime,
                            onDonePressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Done waking period'),
                                    content: Text('${state.getTodayCaloriesSum()} kCal by current waking period. Continue?'),
                                    actions: [
                                      MaterialButton(
                                        child: Text("Cancel"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      MaterialButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          BlocProvider.of<HomeBloc>(context).add(
                                              WakingPeriodEndingEvent(state.currentWakingPeriod!, state.getTodayCaloriesSum()));
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onStartPressed: () {
                              final wakingPeriod = WakingPeriodModel(
                                id: null,
                                description: null,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                startedAt: DateTime.now(),
                                endedAt: null,
                                caloriesValue: 0.0,
                                profileId: state.activeProfile.id!,
                                caloriesLimitGoal: state.activeProfile.caloriesLimitGoal,
                                expectedWakingTimeSeconds: state.activeProfile.getExpectedWakingDuration().inSeconds,
                              );

                              BlocProvider.of<HomeBloc>(context).add(WakingPeriodCreatingEvent(wakingPeriod));
                            },
                          ),
                        ),
                        Column(
                          children: state.dayResults.map((DayResultModel day) {
                            return SizedBox(
                              width: double.infinity,
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                      DateFormat('MMM d, y').format(day.createdAtDay) + ': ' + day.valueSum.round().toString() + ' kcal'),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: Text('Error'),
                  );
                }),
                BlocBuilder<HomeBloc, AbstractHomeState>(
                  builder: (context, state) {
                    if (state is HomeFetchingInProgress) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (state is HomeFetched) {
                      _calorieItems = state.calorieItems;

                      return ReorderableListView.builder(
                        padding: EdgeInsets.all(10),
                        itemBuilder: (context, int index) {
                          final CalorieItemModel calorieItem = _calorieItems[index];

                          final description = DateFormat('HH:mm').format(calorieItem.createdAt) +
                              (calorieItem.description == null ? '' : (', ' + calorieItem.description!.toString()));

                          return ListTile(
                            key: Key(index.toString()),
                            title: Text(
                              calorieItem.value.toStringAsFixed(2) + ' kCal',
                              style: TextStyle(color: (calorieItem.value > 0 ? Colors.red : Colors.green)),
                            ),
                            subtitle: Text(description),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                            onTap: () {
                              showModalBottomSheet<dynamic>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          title: Text('Edit'),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => EditCalorieItemScreen(calorieItem)),
                                            );
                                          },
                                        ),
                                        ListTile(
                                          title: Text('Remove'),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _removeCalorieItem(calorieItem, _calorieItems);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                          );
                        },
                        itemCount: _calorieItems.length,
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = _calorieItems.removeAt(oldIndex);
                            _calorieItems.insert(newIndex, item);
                            BlocProvider.of<HomeBloc>(context).add(CalorieItemListResortingEvent(_calorieItems));
                          });
                        },
                      );
                    }
                    return Center(
                      child: Text('Error'),
                    );
                  },
                ),
                BlocBuilder<HomeBloc, AbstractHomeState>(
                  builder: (context, state) {
                    if (state is HomeFetchingInProgress) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is HomeFetched) {
                      final List<WakingPeriodModel> wakingPeriods = state.wakingPeriods;

                      return ListView.builder(
                        padding: EdgeInsetsDirectional.all(10),
                        itemCount: wakingPeriods.length,
                        itemBuilder: (BuildContext context, int index) {
                          final WakingPeriodModel wakingPeriod = wakingPeriods[index];

                          return ListTile(
                            key: Key(index.toString()),
                            title: Text(wakingPeriod.caloriesValue.toStringAsFixed(2) + ' kCal'),
                            subtitle: Text((DateFormat('MMM d, y HH:mm').format(wakingPeriod.createdAt))),
                            onTap: () {
                              showModalBottomSheet<dynamic>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          title: Text('Edit'),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => EditWakingPeriodScreen(wakingPeriod)),
                                            );
                                          },
                                        ),
                                        ListTile(
                                          title: Text('Remove'),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Remove waking period'),
                                                  content: Text('Continue?'),
                                                  actions: [
                                                    MaterialButton(
                                                      child: Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    MaterialButton(
                                                      child: Text("Ok"),
                                                      onPressed: () {
                                                        _removeWakingPeriod(wakingPeriod);
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                          );
                        },
                      );
                    }

                    return Center(
                      child: Text('Error'),
                    );
                  },
                ),
                BlocBuilder<HomeBloc, AbstractHomeState>(
                  builder: (context, state) {
                    if (state is HomeFetchingInProgress) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is HomeFetched) {
                      final List<DayResultModel> dayResultItems = state.dayResults;

                      return ListView.builder(
                        padding: EdgeInsetsDirectional.all(10),
                        itemCount: dayResultItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          final DayResultModel dayItem = dayResultItems[index];

                          return ListTile(
                            key: Key(index.toString()),
                            title: Text(dayItem.valueSum.toStringAsFixed(2) + ' kCal'),
                            subtitle: Text((DateFormat('MMM d, y').format(dayItem.createdAtDay))),
                            onTap: () {
                              showModalBottomSheet<dynamic>(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return Wrap(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('Show calorie items'),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(builder: (context) => EditWakingPeriodScreen(wakingPeriod)),
                                          // );
                                        },
                                      ),
                                      ListTile(
                                        title: Text('Remove day calories'),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Remove day calories'),
                                                content: Text('Continue?'),
                                                actions: [
                                                  MaterialButton(
                                                    child: Text("Cancel"),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  MaterialButton(
                                                    child: Text("Ok"),
                                                    onPressed: () {
                                                      BlocProvider.of<HomeBloc>(context).add(RemovingDayCaloriesEvent(dayItem.createdAtDay));

                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Day removed')));

                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    }

                    return Center(
                      child: Text('Error'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet<dynamic>(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return BlocBuilder<HomeBloc, AbstractHomeState>(
                builder: (context, state) {
                  if (state is HomeFetched) {
                    final double totalCaloriesNew = _calorieItemPreparedSum.toDouble() + state.getTodayCaloriesSum();

                    return FractionallySizedBox(
                      child: Wrap(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.0),
                            decoration: new BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                              Text('= ${totalCaloriesNew} kCal', textAlign: TextAlign.center),
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
                                              fillColor: Colors.red,
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
                                            _createCalorieItem(_calorieItemPreparedSum, state.activeProfile, _calorieItems,
                                                state.currentWakingPeriod!);
                                          },
                                        ),
                                      ],
                                    ),
                                  ))
                        ],
                      ),
                    );
                  }
                  return Text('...', style: TextStyle(fontSize: 16));
                },
              );
            },
          );
        },
      ),
    );
  }
}

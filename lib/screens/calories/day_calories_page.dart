import 'package:cat_calories/blocs/calories/calories_bloc.dart';
import 'package:cat_calories/blocs/calories/calories_event.dart';
import 'package:cat_calories/blocs/calories/calories_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class DayCaloriesPage extends StatefulWidget {
  final ProfileModel profile;
  final DateTime startDate;

  const DayCaloriesPage(this.profile, this.startDate);

  @override
  State<StatefulWidget> createState() =>
      _DayCaloriesPageState(profile, startDate);
}

class _DayCaloriesPageState extends State<DayCaloriesPage> {
  final ProfileModel profile;
  final DateTime startDate;

  bool _invertSorting = false;

  _DayCaloriesPageState(this.profile, this.startDate);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CaloriesBloc>(context)
        .add(CaloriesFetchProgressEvent(profile, startDate, _invertSorting));

    return Scaffold(
      appBar: AppBar(
        title: Text('Calories ' + DateFormat('MMM d, y').format(startDate),),
        actions: [
          IconButton(
            icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(_invertSorting ? math.pi : 0),
                child: Icon(Icons.sort)),
            onPressed: () {
              setState(() {
                _invertSorting = !_invertSorting;
              });
            },
          ),
        ],
      ),
      body: Container(
        child: BlocBuilder<CaloriesBloc, AbstractCaloriesState>(
          builder: (context, AbstractCaloriesState state) {
            if (state is CaloriesFetchedState) {
              return ListView(
                children:
                    state.calorieItems.map((CalorieItemModel calorieItem) {
                  return ListTile(
                    title: Text('${calorieItem.value} kcal'),
                    subtitle: Text(
                      DateFormat('HH:mm').format(calorieItem.createdAt),
                    ),
                  );
                }).toList(),
              );
            }
            return Center(
              child: Text('Error'),
            );
          },
        ),
      ),
    );
  }
}

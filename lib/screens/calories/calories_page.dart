import 'package:cat_calories/blocs/calories/calories_bloc.dart';
import 'package:cat_calories/blocs/calories/calories_event.dart';
import 'package:cat_calories/blocs/calories/calories_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CaloriesPage extends StatefulWidget {
  final ProfileModel profile;

  const CaloriesPage(this.profile);

  @override
  State<StatefulWidget> createState() => _CaloriesPageState(profile);
}

class _CaloriesPageState extends State<CaloriesPage> {
  final ProfileModel profile;

  bool invertSorting = false;

  _CaloriesPageState(this.profile);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CaloriesBloc>(context)
        .add(CaloriesFetchProgressEvent(profile));

    return Scaffold(
      appBar: AppBar(
        title: Text('Calories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              invertSorting = !invertSorting;
            },
          ),
        ],
      ),
      body: Container(
        child: BlocBuilder<CaloriesBloc, AbstractCaloriesState>(
          builder: (context, AbstractCaloriesState state) {
            print(state);

            if (state is CaloriesFetchedState) {
              return SingleChildScrollView(
                  child: Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: state.calorieItems.map((CalorieItemModel calorieItem) {
                  return TableRow(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(3),
                        child: Text(calorieItem.id.toString()),
                      ),
                      Container(
                        padding: EdgeInsets.all(3),
                        child: Text(calorieItem.value.toStringAsFixed(2)),
                      ),
                      Container(
                        padding: EdgeInsets.all(3),
                        child: Text(calorieItem.description ?? ''),
                      ),
                      Container(
                        padding: EdgeInsets.all(3),
                        child: Text(DateFormat('HH:mm').format(calorieItem.createdAt)),
                      ),
                    ],
                  );
                }).toList(),
              ));
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

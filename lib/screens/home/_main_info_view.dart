import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/screens/home/_waking_period_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MainInfoView extends StatefulWidget {
  MainInfoView({Key? key}) : super(key: key);

  @override
  _MainInfoViewState createState() => _MainInfoViewState();
}

class _MainInfoViewState extends State<MainInfoView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, AbstractHomeState>(builder: (context, state) {
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
                totalCalories: state.getTodayCaloriesSum(),
                currentDateTime: state.nowDateTime,
                caloriesSum: state.getTodayCaloriesSum(),
                activeProfile: state.activeProfile,
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
    });
  }
}

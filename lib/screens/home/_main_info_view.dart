import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_event.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:cat_calories/screens/edit_waking_period_screen.dart';
import 'package:cat_calories/ui/colors.dart';
import 'package:cat_calories/ui/widgets/progress_bar.dart';
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
              child: Card(
                child: Builder(builder: (BuildContext context) {
                  if (state.currentWakingPeriod == null) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: Text(
                              'No active waking periods',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                          Divider(),
                          ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  final wakingPeriod = WakingPeriodModel(
                                    id: null,
                                    description: null,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                    startedAt: DateTime.now(),
                                    endedAt: null,
                                    caloriesValue: 0.0,
                                    profileId: state.activeProfile.id!,
                                    caloriesLimitGoal:
                                        state.activeProfile.caloriesLimitGoal,
                                    expectedWakingTimeSeconds: state
                                        .activeProfile
                                        .getExpectedWakingDuration()
                                        .inSeconds,
                                  );

                                  BlocProvider.of<HomeBloc>(context).add(
                                      WakingPeriodCreatingEvent(wakingPeriod));
                                },
                                child: Text(
                                  'Start waking period',
                                  style: TextStyle(
                                    color: Theme.of(context).buttonColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]);
                  }

                  final int currentTimestamp =
                      (state.nowDateTime.millisecondsSinceEpoch / 1000)
                          .round()
                          .toInt();
                  final int secondsToEndDay =
                      state.currentWakingPeriod!.getToTimestamp() -
                          currentTimestamp;
                  final double allowedCalories =
                      state.currentWakingPeriod!.caloriesLimitGoal -
                          state.currentWakingPeriod!.getCaloriesPerSecond() *
                              secondsToEndDay -
                          state.getPeriodCaloriesEatenSum();
                  final double allowedSeconds = allowedCalories /
                      state.currentWakingPeriod!.getCaloriesPerSecond();
                  final Duration allowedDuration =
                      Duration(seconds: allowedSeconds.round().toInt());

                  final double periodCaloriesEatenPercentage =
                      state.getPeriodCaloriesEatenSum() /
                          state.currentWakingPeriod!.caloriesLimitGoal *
                          100;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          DateFormat('EEEE').format(
                                  state.currentWakingPeriod!.startedAt) +
                              ' waking period',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          DateFormat('MMM d, HH:mm').format(
                                  state.currentWakingPeriod!.startedAt) +
                              ' ~ ' +
                              DateFormat('MMM d, HH:mm').format(
                                  state.currentWakingPeriod!.getToDateTime()),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Builder(builder: (BuildContext context) {
                        final int overLimit =
                            state.currentWakingPeriod!.getToTimestamp() -
                                currentTimestamp;

                        if (overLimit > 0) {
                          final Duration overLimitDuration =
                              Duration(seconds: overLimit);
                          final String overLimitDurationString =
                              (overLimitDuration.inHours)
                                      .toString()
                                      .padLeft(2, '0') +
                                  ':' +
                                  (overLimitDuration.inMinutes.remainder(60))
                                      .toString()
                                      .padLeft(2, '0');

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              'will end after ${overLimitDurationString}',
                              style: TextStyle(
                                color: SuccessColor,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        final Duration overLimitDuration =
                            Duration(seconds: overLimit * -1);
                        final String overLimitDurationString =
                            (overLimitDuration.inHours)
                                    .toString()
                                    .padLeft(2, '0') +
                                ':' +
                                (overLimitDuration.inMinutes.remainder(60))
                                    .toString()
                                    .padLeft(2, '0');

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            'Overlimit: ${overLimitDurationString}',
                            style: TextStyle(
                              color: DangerColor,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                      Divider(),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            margin: EdgeInsets.fromLTRB(5, 5, 10, 5),
                            height: 50.0,
                            width: 50.0,
                            child: CustomPaint(
                              child: Center(
                                child: Text(
                                  periodCaloriesEatenPercentage
                                          .toStringAsFixed(0) +
                                      '%',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              foregroundPainter: ProgressPainter(
                                  defaultCircleColor: Colors.grey.shade200,
                                  percentageCompletedCircleColor:
                                      periodCaloriesEatenPercentage >= 100
                                          ? DangerColor
                                          : DangerLiteColor,
                                  completedPercentage:
                                      periodCaloriesEatenPercentage >= 100
                                          ? 100
                                          : periodCaloriesEatenPercentage,
                                  circleWidth: 3.0),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    child: Text(
                                      'Goal: ' +
                                          state.currentWakingPeriod!
                                              .caloriesLimitGoal
                                              .toString() +
                                          ' kcal/' +
                                          state.currentWakingPeriod!
                                              .getExpectedWakingDuration()
                                              .inHours
                                              .toString() +
                                          'h (${state.currentWakingPeriod!.getCaloriesPerHour().toStringAsFixed(2)} kcal/h)',
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.6)),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child:
                                      Builder(builder: (BuildContext context) {
                                    if (allowedCalories > 0) {
                                      final String stringAllowedDuration =
                                          (allowedDuration.inHours)
                                                  .toString()
                                                  .padLeft(2, '0') +
                                              ':' +
                                              (allowedDuration.inMinutes
                                                      .remainder(60))
                                                  .toString()
                                                  .padLeft(2, '0');

                                      return Text(
                                        'You can eat ' +
                                            allowedCalories.toStringAsFixed(2) +
                                            ' kcal , $stringAllowedDuration',
                                        style: TextStyle(color: SuccessColor),
                                        textAlign: TextAlign.left,
                                      );
                                    }

                                    final String stringAllowedDuration =
                                        (allowedDuration.inHours * -1)
                                                .toString()
                                                .padLeft(2, '0') +
                                            ':' +
                                            (allowedDuration.inMinutes
                                                        .remainder(60) *
                                                    -1)
                                                .toString()
                                                .padLeft(2, '0');

                                    return Text(
                                      'You can eat ' +
                                          allowedCalories.toStringAsFixed(2) +
                                          ' kcal (after $stringAllowedDuration)',
                                      // 'You can eat after',
                                      style: TextStyle(color: DangerColor),
                                      textAlign: TextAlign.left,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      ButtonBar(
                        buttonPadding: EdgeInsets.zero,
                        alignment: MainAxisAlignment.start,
                        children: [
                          MaterialButton(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Text(
                              'Done period',
                              style: TextStyle(
                                color: Theme.of(context).buttonColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Done waking period'),
                                    content: Text(
                                        '${state.getPeriodCaloriesEatenSum()} kcal by current waking period. Continue?'),
                                    actions: [
                                      MaterialButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      MaterialButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          BlocProvider.of<HomeBloc>(context)
                                              .add(WakingPeriodEndingEvent(
                                                  state.currentWakingPeriod!,
                                                  state
                                                      .getPeriodCaloriesEatenSum()));
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          MaterialButton(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditWakingPeriodScreen(
                                            state.currentWakingPeriod!)),
                              );
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: Theme.of(context).buttonColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                      ),
                    ],
                  );
                }),
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Text(
                      'Today: ' +
                          DateFormat('MMM, d').format(state.nowDateTime),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Text(
                        'Today ${state.getPeriodCaloriesEatenSum().toStringAsFixed(2)} from ${state.activeProfile.caloriesLimitGoal.toStringAsFixed(2)} kcal'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Text(
                      'AVG: ${state.get30DaysUntilToday().getAvg().toStringAsFixed(2)} kcal of ${state.get30DaysUntilToday().days.length} days',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Text(
                      'AVG: ${state.get2DaysUntilToday().getAvg().toStringAsFixed(2)} kcal of ${state.get2DaysUntilToday().days.length} days',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children:
                  state.get30DaysUntilToday().days.map((DayResultModel day) {
                return SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(DateFormat('MMM d, y')
                                    .format(day.createdAtDay) +
                                ': ' +
                                day.valueSum.round().toString() +
                                ' kcal'),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '+${day.positiveValueSum.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: DangerColor,
                                ),
                              ),
                              Text(
                                '${day.negativeValueSum.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: SuccessColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

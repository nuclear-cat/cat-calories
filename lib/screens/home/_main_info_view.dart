import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_event.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/day_result.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:cat_calories/screens/edit_waking_period_screen.dart';
import 'package:cat_calories/ui/colors.dart';
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
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No active waking periods',
                          style: TextStyle(color: Colors.black.withOpacity(0.6)),
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
                                caloriesLimitGoal: state.activeProfile.caloriesLimitGoal,
                                expectedWakingTimeSeconds: state.activeProfile.getExpectedWakingDuration().inSeconds,
                              );

                              BlocProvider.of<HomeBloc>(context).add(WakingPeriodCreatingEvent(wakingPeriod));
                            },
                            child: const Text('Start waking period'),
                          ),
                        ],
                      ),
                    ]);
                  }

                  final int currentTimestamp = (state.nowDateTime.millisecondsSinceEpoch / 1000).round().toInt();
                  final int secondsToEndDay = state.currentWakingPeriod!.getToTimestamp() - currentTimestamp;
                  final double allowedCalories = state.currentWakingPeriod!.caloriesLimitGoal -
                      state.currentWakingPeriod!.getCaloriesPerSecond() * secondsToEndDay -
                      state.getTodayCaloriesSum();
                  final double allowedSeconds = allowedCalories / state.currentWakingPeriod!.getCaloriesPerSecond();
                  final Duration allowedDuration = Duration(seconds: allowedSeconds.round().toInt());

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          DateFormat('EEEE').format(state.currentWakingPeriod!.startedAt) + ' waking period',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          DateFormat('MMM d, HH:mm').format(state.currentWakingPeriod!.startedAt) +
                              ' ~ ' +
                              DateFormat('MMM d, HH:mm').format(state.currentWakingPeriod!.getToDateTime()),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),


                      Builder(builder: (BuildContext context) {
                        final int overLimit = state.currentWakingPeriod!.getToTimestamp() - currentTimestamp;

                        if (overLimit > 0) {
                          final Duration overLimitDuration = Duration(seconds: overLimit);
                          final String overLimitDurationString = (overLimitDuration.inHours).toString().padLeft(2, '0') +
                              ':' +
                              (overLimitDuration.inMinutes.remainder(60)).toString().padLeft(2, '0');

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

                        final Duration overLimitDuration = Duration(seconds: overLimit * -1);
                        final String overLimitDurationString = (overLimitDuration.inHours).toString().padLeft(2, '0') +
                            ':' +
                            (overLimitDuration.inMinutes.remainder(60)).toString().padLeft(2, '0');

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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Text(
                          'Goal: ' +
                              state.currentWakingPeriod!.caloriesLimitGoal.toString() +
                              ' kcal/' +
                              state.currentWakingPeriod!.getExpectedWakingDuration().inHours.toString() +
                              'h (${state.currentWakingPeriod!.getCaloriesPerHour().toStringAsFixed(2)} kcal/h)',
                          style: TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Builder(builder: (BuildContext context) {
                        if (allowedCalories > 0) {
                          final String stringAllowedDuration = (allowedDuration.inHours).toString().padLeft(2, '0') +
                              ':' +
                              (allowedDuration.inMinutes.remainder(60)).toString().padLeft(2, '0');

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              'You can eat ' + allowedCalories.toStringAsFixed(2) + ' kcal , $stringAllowedDuration',
                              style: TextStyle(color: Colors.green),
                            ),
                          );
                        }

                        final String stringAllowedDuration = (allowedDuration.inHours * -1).toString().padLeft(2, '0') +
                            ':' +
                            (allowedDuration.inMinutes.remainder(60) * -1).toString().padLeft(2, '0');

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            'You can eat ' + allowedCalories.toStringAsFixed(2) + ' kcal (after $stringAllowedDuration)',
                            // 'You can eat after',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }),
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
                                    content: Text('${state.getTodayCaloriesSum()} kCal by current waking period. Continue?'),
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
                          ),
                          MaterialButton(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            onPressed: () {
                              // Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditWakingPeriodScreen(state.currentWakingPeriod!)),
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

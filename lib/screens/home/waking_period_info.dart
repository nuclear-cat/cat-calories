import 'package:cat_calories/models/waking_period_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../edit_waking_period_screen.dart';

class WakingPeriodInfo extends StatelessWidget {
  final WakingPeriodModel? wakingPeriod;
  final double caloriesLimitGoal;
  final double totalCalories;
  final DateTime currentDateTime;
  final VoidCallback onDonePressed;
  final VoidCallback onStartPressed;

  WakingPeriodInfo({
    required this.wakingPeriod,
    required this.caloriesLimitGoal,
    required this.totalCalories,
    required this.currentDateTime,
    required this.onDonePressed,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Builder(builder: (BuildContext context) {
          if (wakingPeriod == null) {
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
                    onPressed: () => onStartPressed(),
                    child: const Text('Start waking period'),
                  ),
                ],
              ),
            ]);
          }

          final int fromTimestamp = (wakingPeriod!.startedAt.millisecondsSinceEpoch / 1000).round().toInt();
          final DateTime toDateTime = wakingPeriod!.startedAt.add(wakingPeriod!.getExpectedWakingDuration());
          final int toTimestamp = (toDateTime.millisecondsSinceEpoch / 1000).round().toInt();
          final int currentTimestamp = (currentDateTime.millisecondsSinceEpoch / 1000).round().toInt();
          final int totalRangeSeconds = toTimestamp - fromTimestamp;
          final double caloriesPerSecond = wakingPeriod!.caloriesLimitGoal / totalRangeSeconds;
          final int secondsToEndDay = toTimestamp - currentTimestamp;
          final double allowedCalories = wakingPeriod!.caloriesLimitGoal - caloriesPerSecond * secondsToEndDay - totalCalories;

          final double allowedSeconds = allowedCalories / caloriesPerSecond;
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
                  DateFormat('EEEE').format(wakingPeriod!.startedAt) + ' waking period',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  DateFormat('MMM d, HH:mm').format(wakingPeriod!.startedAt) +
                      ' ~ ' +
                      DateFormat('MMM d, HH:mm').format(toDateTime),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text(
                  'Goal: ' +
                      wakingPeriod!.caloriesLimitGoal.toString() +
                      ' kcal in ' +
                      wakingPeriod!.getExpectedWakingDuration().inHours.toString() +
                      ' hours',
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
                      'You can eat ' + allowedCalories.toStringAsFixed(2) + ', $stringAllowedDuration',
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
                    'You can eat ' + allowedCalories.toStringAsFixed(2) + ' (after $stringAllowedDuration)',
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
                    child: const Text('Done period'),
                    onPressed: () => onDonePressed(),
                  ),
                  MaterialButton(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    onPressed: () {
                      // Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditWakingPeriodScreen(wakingPeriod!)),
                      );
                    },
                    child: const Text('Edit'),
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
    );
  }
}

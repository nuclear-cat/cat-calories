import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_event.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../edit_waking_period_screen.dart';

class WakingPeriodsView extends StatefulWidget {
  WakingPeriodsView({Key? key}) : super(key: key);

  @override
  _WakingPeriodsViewState createState() => _WakingPeriodsViewState();
}

class _WakingPeriodsViewState extends State<WakingPeriodsView> {

  void _removeWakingPeriod(WakingPeriodModel wakingPeriod) {
    BlocProvider.of<HomeBloc>(context).add(WakingPeriodDeletingEvent(wakingPeriod));

    final snackBar = SnackBar(content: Text('Item removed'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<HomeBloc, AbstractHomeState>(
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
    );
  }
}
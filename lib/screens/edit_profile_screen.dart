import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_event.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  ProfileModel profile;

  EditProfileScreen(this.profile);

  @override
  EditProfileScreenState createState() => EditProfileScreenState(this.profile);
}

class EditProfileScreenState extends State<EditProfileScreen> {
  ProfileModel profile;

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _wakingTimeHours = new TextEditingController();
  TextEditingController _caloriesLimitGoal = new TextEditingController();

  EditProfileScreenState(this.profile);

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    double _currentSliderValue = 20;

    _nameController.text = profile.name;
    _wakingTimeHours.text = profile.getExpectedWakingDuration().inHours.toString();
    _caloriesLimitGoal.text = profile.caloriesLimitGoal.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wakingTimeHours.dispose();
    _caloriesLimitGoal.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit profile', style: TextStyle(fontSize: 16)),
        toolbarHeight: 45,
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
            ),
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              profile.caloriesLimitGoal = double.parse(_caloriesLimitGoal.text);
              profile.setExpectedWakingDuration(Duration(hours: int.parse(_wakingTimeHours.text)));
              profile.name = _nameController.text;
              profile.updatedAt = DateTime.now();

              BlocProvider.of<HomeBloc>(context).add(ProfileUpdatingEvent(profile));

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<HomeBloc, AbstractHomeState>(builder: (BuildContext context, state) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Wrap(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    controller: _nameController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter profile name';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Waking time (hours)',
                      suffix: Text('hours'),
                    ),
                    controller: _wakingTimeHours,
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please waking time';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Calories limit goal',
                      suffix: Text('kCal'),
                    ),
                    controller: _caloriesLimitGoal,
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter calories limit goal';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Wrap(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  controller: _nameController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter profile name';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Waking time (hours)',
                    suffix: Text('hours'),
                  ),
                  controller: _wakingTimeHours,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please waking time';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Calories limit goal',
                    suffix: Text('kCal'),
                  ),
                  controller: _caloriesLimitGoal,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter calories limit goal';
                    }

                    return null;
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

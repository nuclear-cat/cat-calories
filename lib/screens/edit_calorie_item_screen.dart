import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_event.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCalorieItemScreen extends StatefulWidget {
  final CalorieItemModel calorieItem;

  EditCalorieItemScreen(this.calorieItem);

  @override
  EditCalorieItemScreenState createState() =>
      EditCalorieItemScreenState(this.calorieItem);
}

class EditCalorieItemScreenState extends State<EditCalorieItemScreen> {
  TextEditingController _valueController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();

  CalorieItemModel calorieItem;

  EditCalorieItemScreenState(this.calorieItem);

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _valueController.text = calorieItem.value.toString();
    _descriptionController.text =
        (calorieItem.description == null ? '' : calorieItem.description)
            .toString();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Edit calorie item',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            )),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
            ),
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              calorieItem.value = double.parse(_valueController.text);
              calorieItem.description = _descriptionController.text.length == 0
                  ? null
                  : _descriptionController.text;

              BlocProvider.of<HomeBloc>(context)
                  .add(CalorieItemListUpdatingEvent(calorieItem, [], () {
                Navigator.of(context).pop();
              }));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, AbstractHomeState>(
          builder: (BuildContext context, state) {
        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Wrap(
              children: <Widget>[
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'kcal',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter kcal value';
                    }

                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 0,
                  ),
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

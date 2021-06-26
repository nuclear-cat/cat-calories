import 'package:cat_calories/blocs/home/home_bloc.dart';
import 'package:cat_calories/blocs/home/home_event.dart';
import 'package:cat_calories/blocs/home/home_state.dart';
import 'package:cat_calories/models/calorie_item_model.dart';
import 'package:cat_calories/models/product_model.dart';
import 'package:cat_calories/models/waking_period_model.dart';
import 'package:cat_calories/ui/colors.dart';
import 'package:cat_calories/ui/widgets/caclulator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../edit_product_screen.dart';

class ProductsView extends StatefulWidget {
  ProductsView({Key? key}) : super(key: key);

  @override
  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  TextEditingController productWeightController = TextEditingController();

  void _createCalorieItem(ProductModel product, List<CalorieItemModel> calorieItems, WakingPeriodModel wakingPeriod) {
    final String expression = productWeightController.text;

    if (expression.length == 0) {
      return;
    }

    BlocProvider.of<HomeBloc>(context)
        .add(EatProductEvent(product, expression, wakingPeriod, calorieItems, (CalorieItemModel calorieItem) {
      final snackBar = SnackBar(content: Text('${calorieItem.value.toStringAsFixed(2)} kcal added'));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      productWeightController.text = '';
    }));
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
          final List<ProductModel> products = state.products;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final ProductModel product = products[index];

              return ListTile(
                contentPadding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                key: Key(index.toString()),
                title: Text(product.title),
                subtitle: Text('${product.calorieContent} kcal'),
                onTap: () {
                  showModalBottomSheet<dynamic>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return Wrap(
                        children: <Widget>[
                          ListTile(
                            title: Text('To eat'),
                            onTap: () {
                              Navigator.of(context).pop();

                              showModalBottomSheet<dynamic>(
                                barrierColor: Colors.black.withOpacity(0.2),
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(builder: (BuildContext context, StateSetter stateSetter) {
                                    return FractionallySizedBox(
                                      child: Wrap(
                                        children: <Widget>[
                                          Builder(
                                            builder: (context) => Form(
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    color: Color(0xFFEEEEEE),
                                                    child: TextFormField(
                                                      decoration: InputDecoration(
                                                        fillColor: SuccessColor,
                                                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                        suffix: Text('g'),
                                                        prefix: Text('+'),
                                                      ),
                                                      validator: (value) {
                                                        // if (value.isEmpty) {
                                                        //   return 'Please enter some value';
                                                        // }
                                                        return null;
                                                      },
                                                      maxLines: 1,
                                                      controller: productWeightController,
                                                    ),
                                                  ),
                                                  CalculatorWidget(
                                                    controller: productWeightController,
                                                    onPressed: () {
                                                      _createCalorieItem(product, state.periodCalorieItems, state.currentWakingPeriod!);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  });
                                },
                              );
                            },
                          ),
                          ListTile(
                            title: Text('Edit'),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProductScreen(product)),
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
                                    title: Text('Remove product'),
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
                                          BlocProvider.of<HomeBloc>(context).add(DeleteProductEvent(product));

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(content: Text('Product ${product.title} removed')));

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
    );
  }
}

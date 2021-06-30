import 'package:cat_calories/database/database.dart';
import 'package:cat_calories/models/product_model.dart';
import 'package:cat_calories/models/profile_model.dart';
import 'package:sqflite/sqflite.dart';

class ProductRepository {

  static const String tableName = 'products';

  Future<List<ProductModel>> fetchAll() async {
    final productsResult = await DBProvider.db.query(tableName, orderBy: 'sort_order ASC');

    return productsResult
        .map((element) => ProductModel.fromJson(element))
        .toList();
  }

  Future<List<ProductModel>> fetchByProfile(ProfileModel profile) async {
    final productsResult = await DBProvider.db.query(tableName, where: 'profile_id = ?', whereArgs: [profile.id!], orderBy: 'id DESC');

    return productsResult
        .map((element) => ProductModel.fromJson(element))
        .toList();
  }

  Future<ProductModel> insert(ProductModel product) async {
    product.id = await DBProvider.db.insert(tableName, product.toJson());

    return product;
  }

  Future<int> delete(ProductModel product) async {
    return await DBProvider.db
        .delete(tableName, where: 'id = ?', whereArgs: [product.id]);
  }

  Future<ProductModel> update(ProductModel product) async {
    await DBProvider.db.update(tableName, product.toJson(),
        where: 'id = ?', whereArgs: [product.id]);

    return product;
  }

  Future resort(List<ProductModel> products) async {
    Batch batch = await DBProvider.db.batch();

    for (var i = 0; i < products.length; i++) {
      final ProductModel calorieItem = products[i];
      batch.update(tableName, {'sort_order': i}, where: 'id = ?', whereArgs: [calorieItem.id]);
    }

    return await batch.commit();
  }

  Future<void> offsetSortOrder() async {
    await DBProvider.db.rawQuery('UPDATE $tableName SET sort_order = sort_order + 1');
  }
}

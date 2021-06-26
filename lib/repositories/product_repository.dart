import 'package:cat_calories/database/database.dart';
import 'package:cat_calories/models/product_model.dart';
import 'package:cat_calories/models/profile_model.dart';

class ProductRepository {

  static const String tableName = 'products';

  Future<List<ProductModel>> fetchAll() async {
    final productsResult = await DBProvider.db.query(tableName);

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
}

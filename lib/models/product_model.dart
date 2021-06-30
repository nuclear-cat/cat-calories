class ProductModel {
  int? id;
  String title;
  String? description;
  int usesCount;
  DateTime createdAt;
  DateTime updatedAt;
  int profileId;
  int? barcode;
  double? calorieContent;
  double? proteins;
  double? fats;
  double? carbohydrates;
  int sortOrder;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.usesCount,
    required this.createdAt,
    required this.updatedAt,
    required this.profileId,
    required this.barcode,
    required this.calorieContent,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
    required this.sortOrder,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        usesCount: json['uses_count'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at']),
        profileId: json['profile_id'],
        barcode: json['barcode'],
        calorieContent: json['calorie_content'],
        proteins: json['proteins'],
        fats: json['fats'],
        carbohydrates: json['carbohydrates'],
        sortOrder: json['sort_order'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'uses_count': usesCount,
        'profile_id': profileId,
        'barcode': barcode,
        'calorie_content': calorieContent,
        'proteins': proteins,
        'fats': fats,
        'carbohydrates': carbohydrates,
        'sort_order': sortOrder,
      };
}

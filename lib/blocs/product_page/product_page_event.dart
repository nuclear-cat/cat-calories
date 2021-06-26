abstract class AbstractProductPageEvent {}

class FetchProductPageEvent extends AbstractProductPageEvent {}

class FetchedProductPageEvent extends AbstractProductPageEvent {}

class CreateProductEvent extends AbstractProductPageEvent {
  final String title;
  final String? description;
  final int? barcode;
  final double? calorieContent;
  final double? proteins;
  final double? fats;
  final double? carbohydrates;

  CreateProductEvent({
    required this.title,
    required this.description,
    required this.barcode,
    required this.calorieContent,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
  });
}

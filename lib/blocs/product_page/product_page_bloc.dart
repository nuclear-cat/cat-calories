import 'package:cat_calories/blocs/product_page/product_page_event.dart';
import 'package:cat_calories/blocs/product_page/product_page_state.dart';
import 'package:cat_calories/repositories/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductPageBloc extends Bloc<AbstractProductPageEvent, AbstractProductPageState> {
  ProductRepository productsRepository = ProductRepository();

  ProductPageBloc(AbstractProductPageState initialState) : super(initialState);

  @override
  Stream<AbstractProductPageState> mapEventToState(AbstractProductPageEvent event) async* {
    if (event is FetchProductPageEvent) {
      yield* _fetchData();
    } else if (event is CreateProductEvent) {
      yield* _fetchData();
    }
  }

  Stream<ProductPageFetchedState> _fetchData() async* {
    // final List<ProductModel> products = await productsRepository.fetchAll();

    yield ProductPageFetchedState();
  }

  // Future<void> _createProduct(CreateProductEvent event) async {
  //   final product = ProductModel(
  //     id: null,
  //     title: event.title,
  //     description: event.description,
  //     usesCount: 0,
  //     createdAt: DateTime.now(),
  //     profileId: _activeProfile!.id!,
  //     barcode: event.barcode,
  //     calorieContent: event.calorieContent,
  //     proteins: event.proteins,
  //     fats: event.fats,
  //     carbohydrates: event.carbohydrates,
  //   );
  //
  //   await productsRepository.update(product);
  // }
}

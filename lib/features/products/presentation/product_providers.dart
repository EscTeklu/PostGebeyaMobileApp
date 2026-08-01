import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/customize/models/product_model.dart';
import 'package:nopcommerce_mobile/features/products/data/product_repository.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_subscription_controller.dart';
import 'package:nopcommerce_mobile/utils/base_nop_state.dart';

final productsRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

// Home page providers — NOT autoDispose so data survives navigation
final mostSoldProductsListFutureProvider =
    FutureProvider<List<Product>?>((ref) async {
  return ref.watch(productsRepositoryProvider).getMostSoldProducts();
});

final newProductsListFutureProvider =
    FutureProvider<List<Product>?>((ref) async {
  return ref.watch(productsRepositoryProvider).getNewProducts();
});

final discountProductsListFutureProvider =
    FutureProvider<List<Product>?>((ref) async {
  return ref.watch(productsRepositoryProvider).getDiscountProducts();
});

final homePageProductsListFutureProvider =
    FutureProvider<BuiltList<ProductOverviewModelDto>?>((ref) async {
  return ref.watch(productsRepositoryProvider).getHomePageProducts();
});

// Product detail providers — autoDispose so each product page fetches fresh
final relatedProductsListProvider = FutureProvider.autoDispose
    .family<BuiltList<ProductOverviewModelDto>?, int>((ref, id) async {
  return ref.watch(productsRepositoryProvider).getRelatedProducts(id);
});

final productProvider = FutureProvider.autoDispose
    .family<ProductDetailsModelDto?, int?>((ref, id) async {
  return ref.watch(productsRepositoryProvider).getProductDetails(id!, null);
});

final productSubscriptionControllerProvider = StateNotifierProvider.autoDispose<
    ProductSubscriptionController, BaseNopState>((ref) {
  return ProductSubscriptionController(
      productRepository: ref.watch(productsRepositoryProvider));
});

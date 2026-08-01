import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/features/app/repository_provider.dart';
import 'package:nopcommerce_mobile/features/products/data/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

final categoriesListFutureProvider =
    FutureProvider<BuiltList<CategorySimpleModelDto>?>((ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return catalogRepository.fetchAllCategoriesList();
});

final homePageCategoriesListFutureProvider =
    FutureProvider<BuiltList<CategorySimpleModelDto>?>((ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return catalogRepository.getHomePageCategories();
});

// Persistent provider: fetches all categories + their products once,
// cached for the session. Invalidate via ref.invalidate() on pull-to-refresh.
final categoryProductMapProvider =
    FutureProvider<Map<CategorySimpleModelDto, List<ProductOverviewModelDto>>>(
        (ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  final allCategories = await catalogRepository.fetchAllCategoriesList();

  final Map<CategorySimpleModelDto, List<ProductOverviewModelDto>>
      categoryProductMap = {};

  for (var category in allCategories!) {
    final result = await catalogRepository.getProductsById(
      categoryId: category.id!,
    );
    categoryProductMap[category] =
        result?.catalogProductsModel?.products?.toList() ??
        <ProductOverviewModelDto>[];
  }

  return categoryProductMap;
});

final manufacturersListFutureProvider =
    FutureProvider.autoDispose<BuiltList<ManufacturerModelDto>?>((ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return catalogRepository.fetchManufacturersList();
});

final vendorsListFutureProvider =
    FutureProvider.autoDispose<BuiltList<VendorModelDto>?>((ref) async {
  final catalogRepository = ref.watch(catalogRepositoryProvider);
  return catalogRepository.fetchVendorsList();
});

final searchProductsAutocompleteFutureProvider = FutureProvider.autoDispose
    .family<BuiltList<SearchTermAutoCompleteResponse>?, String?>(
        (ref, term) async {
  final catalogRepository =
      ref.watch(getRepositoryProvider(() => CatalogRepository()));
  return catalogRepository.searchProductsAutocomplete(term: term!);
});

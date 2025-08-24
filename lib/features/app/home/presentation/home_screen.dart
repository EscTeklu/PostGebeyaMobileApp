
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/text_link.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/models/discounted_product.dart';
import 'package:nopcommerce_mobile/customize/models/new_product_model.dart';
import 'package:nopcommerce_mobile/customize/models/product.dart';
import 'package:nopcommerce_mobile/customize/services/api_service.dart';
import 'package:nopcommerce_mobile/customize/widgets/slides_carousel.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/widgets/single_image_offer.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/widgets/top_categories.dart';
import 'package:nopcommerce_mobile/features/app/locale/app_locale_provider.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/catalog_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/product_search.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product_card.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/products_line.dart';
import 'package:nopcommerce_mobile/features/settings/presentation/settings_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  const HomePageScreen({super.key});

  @override
  ConsumerState<HomePageScreen> createState() => _HomePageScreen();
}

class _HomePageScreen extends ConsumerState<HomePageScreen> {
  //added for MostSold, NewProducts, Discount
  final ApiService apiService = ApiService();
  late Future<List<Product>> mostSoldProducts;
  late Future<List<DiscountProduct>> discountedProducts;
  late Future<List<NewProductModel>> newProducts;
  //
  String selectedFilter = 'All';
  //
  late AsyncValue<BuiltList<ProductOverviewModelDto>?> productsListValue;
  late AsyncValue<BuiltList<CategorySimpleModelDto>?> categoriesListValue;

  //
  Widget _buildMostSoldProductList() {
    mostSoldProducts = apiService.getMostSoldProducts();
    print('MOST SOLD : $mostSoldProducts');
    return FutureBuilder<List<Product>>(
      future: mostSoldProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Error:No Network ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(child: Text('No products found.'));
        }
        for (var value in products){
          print('MOST SOLD : $value');
        }

        return SizedBox(
          height: 350,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7, // adjust height
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  context.goNamed(
                    Routes.product.name,
                    pathParameters: {
                      'id': product.id.toString(),
                    },
                  );
                  /*showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(product.name),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            Image.network(product.defaultPictureUrl),
                            const SizedBox(height: 8),
                            Text(product.shortDescription),
                            const SizedBox(height: 8),
                            Text("Price: \$${product.price}"),
                            *//*if (product.dto.oldPrice > 0)
                              Text(
                                "Old Price: \$${product.oldPrice}",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            Text("Stock: ${product.stockQuantity}"),*//*
                          ],
                        ),
                      ),
                    ),
                  );*/
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.defaultPictureUrl ?? "https://via.placeholder.com/150",
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.shortDescription ?? "No description available",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "\$${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

      },
    );
  }

  Widget _buildNewProductList() {
    newProducts = apiService.fetchNewProducts();
    print('NEW PRODUCTS : $newProducts');
    return FutureBuilder<List<NewProductModel>>(
      future: newProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error:No Network'));
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

       return SizedBox(
          height: 350,
          child:GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7, // adjust height
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  context.goNamed(
                    Routes.product.name,
                    pathParameters: {
                      'id': product.dto.id.toString(),
                    },
                  );
                  /*showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(product.dto.name),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            Image.network(product.defaultPictureUrl),
                            const SizedBox(height: 8),
                            Text(product.dto.fullDescription),
                            const SizedBox(height: 8),
                            Text("Price: \$${product.dto.price}"),
                            if (product.dto.oldPrice > 0)
                              Text(
                                "Old Price: \$${product.dto.oldPrice}",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            Text("Stock: ${product.dto.stockQuantity}"),
                          ],
                        ),
                      ),
                    ),
                  );*/
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.defaultPictureUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.dto.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.dto.shortDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "\$${product.dto.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ) ,
        );
      },
    );
  }

  Widget _buildDiscountedList() {
    discountedProducts = apiService.getDiscountedProducts();
    print('DISCOUNT : $discountedProducts');
    return FutureBuilder<List<DiscountProduct>>(
      future: discountedProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: No Network'));
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(child: Text('No discounted products.'));
        }
       return SizedBox(
          height: 350,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7, // adjust height
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  context.goNamed(
                    Routes.product.name,
                    pathParameters: {
                      'id': product.id.toString(),
                    },
                  );
                  /*showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(product.dto.name),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            Image.network(product.defaultPictureUrl),
                            const SizedBox(height: 8),
                            Text(product.dto.fullDescription),
                            const SizedBox(height: 8),
                            Text("Price: \$${product.dto.price}"),
                            if (product.dto.oldPrice > 0)
                              Text(
                                "Old Price: \$${product.dto.oldPrice}",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            Text("Stock: ${product.dto.stockQuantity}"),
                          ],
                        ),
                      ),
                    ),
                  );*/
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.defaultPictureUrl?.isNotEmpty == true
                                ? product.defaultPictureUrl!
                                : "https://via.placeholder.com/150",
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.shortDescription ?? "No description",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "\$${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  //

  void updateProductList(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {

    //final homePageSliderImages = ref.watch(homePageSliderImagesFutureProvider);
    productsListValue = ref.watch(homePageProductsListFutureProvider);
    categoriesListValue = ref.watch(categoriesListFutureProvider);
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.accentColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        // Removes default back button
        titleSpacing: 0,
        // Ensures title starts at the very beginning
        leadingWidth: 0,
        centerTitle: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: () {
                  context.pushNamed(Routes.home.name);
                },
                child: Image.asset(
                  'assets/bottom_logo.png',
                  height: 60,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            ProductSearch(),
            const SizedBox(width: 0),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey.shade400,
              margin: const EdgeInsets.only(right: 8),
            ),
            LanguageSelectorDropdown(), // ← neatly fitted here
            //const Icon(Icons.shopping_cart, color: Colors.green),

            //const Text('0'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(homePageProductsListFutureProvider);
          return ref.refresh(homePageCategoriesListFutureProvider.future);
        },
        child: ListView(
          controller: ScrollController(),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: SlidesCarousel(),
                ),
                //const CarouselImage(),//
                //HomePageSlider(homePageSliderImages),

                TopCategories(categoriesListValue),

                FilterRow(onFilterSelected: updateProductList),
                if (selectedFilter == 'All')
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: ProductsLine(
                      valueObj: productsListValue,
                      title: ' ',
                    ),
                  ),
                if (selectedFilter == 'Most sold')
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _buildMostSoldProductList(),
                  ),

                if (selectedFilter == 'New products')
                  _buildNewProductList(),
                if (selectedFilter == 'Discounts')
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _buildDiscountedList(),
                  ),
                const SizedBox(height: 6),
                const CategoryProductGrid(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class CategoryProductGrid extends ConsumerWidget {
  const CategoryProductGrid({super.key});

  Future<Map<CategorySimpleModelDto, List<ProductOverviewModelDto>>>
  fetchProductsByCategory(WidgetRef ref) async {
    final catalogRepository = ref.read(catalogRepositoryProvider);
    final allCategories = await catalogRepository.fetchAllCategoriesList();

    Map<CategorySimpleModelDto, List<ProductOverviewModelDto>>
    categoryProductMap = {};

    for (var category in allCategories!) {
      final result = await catalogRepository.getProductsById(
        categoryId: category.id!,
      );
      final products =
          result?.catalogProductsModel?.products?.toList() ??
          <ProductOverviewModelDto>[];
      categoryProductMap[category] = products;
    }

    return categoryProductMap;
  }
  //

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<
      Map<CategorySimpleModelDto, List<ProductOverviewModelDto>>
    >(
      future: fetchProductsByCategory(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final categoryMap = snapshot.data!;
        return Column(
          children:
              categoryMap.entries.map((entry) {
                final category = entry.key;
                final products = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    if (category.pictureModel?.imageUrl != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical:5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //DealOfTheDay(),
                            SingleImageOffer(
                              headTitle: 'EthioCommerce Market | ',
                              subTitle: 'Extra up to Br. 2000 off with coupons',
                              image: category.pictureModel!.imageUrl!,
                              productCategory: category.name ?? 'Unnamed',
                            ),
                            //SizedBox.square(dimension: 8)
                          ],
                        ),
                      ),
                    if(products.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          if (category.pictureModel?.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  category.pictureModel!.imageUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              category.name ?? 'Unnamed',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Row(
                            children: [
                              TextLink(
                                label: "View All",
                                onTap:
                                    () => {
                                      context.pushNamed(
                                        Routes.category.name,
                                        pathParameters: {
                                          'id': category.id.toString(),
                                        },
                                      ),
                                    },
                                textStyle: Theme.of(
                                  context,
                                ).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              /* Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blueAccent,
                                  ),
                                ), */
                              Icon(
                                Icons.more_vert,
                                size: 16,
                                color: Colors.black,
                              ), // Changed to a more common "see all" icon
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: products.isNotEmpty ? 270: 0, // Increased height to prevent ProductCard overflow (was 200)
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final price = product.productPrice?.price ?? 'N/A';
                          final rating =
                              product.reviewOverviewModel!.totalReviews ?? 0.0;

                          return ProductCard(
                            width: 150,
                            product: product,
                            onPressed:
                                () => context.goNamed(
                                  Routes.product.name,
                                  pathParameters: {
                                    'id': product.id!.toString(),
                                  },
                                ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
        );
      },
    );
  }
}
//
class LanguageSelectorDropdown extends ConsumerStatefulWidget {
  const LanguageSelectorDropdown({super.key});

  @override
  ConsumerState<LanguageSelectorDropdown> createState() =>
      _LanguageSelectorDropdownState();
}

class _LanguageSelectorDropdownState
    extends ConsumerState<LanguageSelectorDropdown> {
  int? selectedLanguageId;

  @override
  Widget build(BuildContext context) {
    final languageSelectorAsync = ref.watch(languageSelectorProvider);

    return languageSelectorAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const Icon(Icons.language_outlined, color: Colors.red),
      data: (languageDto) {
        final builder = languageDto?.toBuilder();
        if (builder == null) return const SizedBox();

        selectedLanguageId ??= builder.currentLanguageId;

        return Container(
          width: 50, // Force consistent width for AppBar fitting
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedLanguageId,
              icon: Icon(Icons.language,
                  color: Colors.white,),
              style: Theme.of(context).textTheme.bodyMedium,
              isExpanded: true,
              items: builder.availableLanguages
                  .build()
                  .map((item) => DropdownMenuItem(
                value: item.id,
                child: Text(item.name ?? "",
                    overflow: TextOverflow.ellipsis,
                   style:  TextStyle(color: Theme.of(context).colorScheme.primary,fontWeight: FontWeight.w900)),
              ))
                  .toList(),
              onChanged: (int? value) async {
                final locale = builder.availableLanguages
                    .build()
                    .firstWhere((lang) => lang.id == value);

                ref.read(appLocaleStateProvider.notifier).toggleAppLocale(
                  context,
                  ref,
                  locale.name!.toLowerCase(),
                );

                final controller =
                ref.read(languageControllerProvider.notifier);
                await controller.setLanguage(
                    builder.currentLanguageId ?? 0);

                setState(() {
                  selectedLanguageId = value!;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

//

/*class CategorySection extends StatelessWidget {
  final String title;
  final List<ProductCardScroll> products;

  const CategorySection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: const [
                  Text('See All', style: TextStyle(color: Colors.blue)),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ), // Changed to a more common "see all" icon
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height:
              270, // Increased height to prevent ProductCard overflow (was 200)
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) => products[index],
          ),
        ),
      ],
    );
  }
}*/

class ProductCardScroll extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double rating;
  final String price;
  final bool isNew;

  const ProductCardScroll({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.price,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51), // withAlpha is correct
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
        children: [
          Stack(
            children: [
              ClipRRect(
                // Added ClipRRect to round corners of the image
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity, // Ensure image fills width
                  fit: BoxFit.cover,
                ),
              ),
              if (isNew)
                const Positioned(
                  top: 5,
                  left: 5,
                  child: Chip(
                    // Use Chip for "New" label for better visual
                    label: Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.green,
                    materialTapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap, // Shrink tap target size
                    padding: EdgeInsets.zero,
                  ),
                ),
              const Positioned(
                top: 5,
                right: 5,
                child: Icon(Icons.favorite_border, color: Colors.pink),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2, // Limit lines for name
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                ),
                const SizedBox(height: 4),
                Row(
                  children: List<Widget>.generate(
                    5,
                    (int index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color:
                          Colors
                              .amber, // Changed to amber for typical star color
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Instead of Spacer and Align, use a Row with Spacer for alignment within its own space
          const Expanded(
            // Allow the rest of the content to fill available space
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Icon(Icons.add_circle, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//PRODUCT FILTER
class FilterRow extends StatefulWidget {
  final Function(String) onFilterSelected;

  const FilterRow({super.key, required this.onFilterSelected});

  @override
  _FilterRowState createState() => _FilterRowState();
}

class _FilterRowState extends State<FilterRow> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> filters = [
    {'label': 'All', 'icon': Icons.list},
    {'label': 'Most sold', 'icon': Icons.trending_up},
    {'label': 'New products', 'icon': Icons.new_releases},
    {'label': 'Discounts', 'icon': Icons.local_offer},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45, // Reduced height
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              filters
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ), // Reduced spacing
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedFilter = filter['label'];
                          });
                          widget.onFilterSelected(filter['label']);
                        },
                        icon: Icon(
                          filter['icon'],
                          size: 18,
                          color:
                              selectedFilter == filter['label']
                                  ? GlobalVariables.backgroundColor
                                  : GlobalVariables.secondaryColor,
                        ), // Smaller icon
                        label: Text(
                          filter['label'],
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                selectedFilter == filter['label']
                                    ? GlobalVariables.backgroundColor
                                    : Colors.black,
                          ),
                        ), // Smaller text
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 10,
                          ), // Compact padding
                          backgroundColor:
                              selectedFilter == filter['label']
                                  ? GlobalVariables.accentColor
                                  : Colors.white70,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

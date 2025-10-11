
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_icon_button.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/common_widgets/text_link.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/models/product_model.dart';
import 'package:nopcommerce_mobile/customize/services/api_service.dart';
import 'package:nopcommerce_mobile/customize/widgets/slides_carousel.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/widgets/top_categories.dart';
import 'package:nopcommerce_mobile/features/app/locale/app_locale_provider.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/cart/domain/cart_item.dart';
import 'package:nopcommerce_mobile/features/cart/presentation/add_to_card/add_to_cart_controller.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/catalog_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/product_search.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product_card.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/products_line.dart';
import 'package:nopcommerce_mobile/features/settings/presentation/settings_providers.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/themes/nopCommerce/dist/styledictionary/flutter/style_dictionary.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  const HomePageScreen({super.key});

  @override
  ConsumerState<HomePageScreen> createState() => _HomePageScreen();
}

class _HomePageScreen extends ConsumerState<HomePageScreen> {
  //added for MostSold, NewProducts, Discount
  final ApiService apiService = ApiService();
  //late Future<List<Product>> mostSoldProducts;
  late AsyncValue<List<Product>?> mostSoldProducts;
  late AsyncValue<List<Product>?> discountedProducts;
  late AsyncValue<List<Product>?> newProducts;
  //
  String selectedFilter = 'All';
  //
  late AsyncValue<BuiltList<ProductOverviewModelDto>?> productsListValue;
  late AsyncValue<BuiltList<CategorySimpleModelDto>?> categoriesListValue;

  //
  Widget _buildProductListWidget(AsyncValue<List<Product>?> valueObj) {
    return AsyncValueWidget<List<Product>?>(
      value: valueObj,
      data:
          (products) =>
      products?.isEmpty ?? true
          ? Container()
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*if (title?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                title!,
                style: titleFontStyle,
              ),
            ),*/
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ProductsLayoutLine(
              itemCount: products!.length,
              itemBuilder: (_, index) {
                final producto = products[index];
                return ProductCardo(
                  width: 195,
                  product: producto,
                  onPressed:
                      () => context.pushNamed(
                    Routes.product.name,
                    pathParameters: {
                      'id': producto.id.toString(),
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

  }

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
    mostSoldProducts = ref.watch(mostSoldProductsListFutureProvider);
    newProducts = ref.watch(newProductsListFutureProvider);
    discountedProducts = ref.watch(discountProductsListFutureProvider);

    //print("MOST SOLD : $mostSoldProducts");
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          RefreshIndicator(
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
                      padding: const EdgeInsets.only(top: 2),
                      child: SlidesCarousel(),
                    ),
                    //const CarouselImage(),//
                    //HomePageSlider(homePageSliderImages),
                    //Text(user.toString(), style: TextStyle(backgroundColor: Colors.white),),
                    //ProductGridScreen(),
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
                    if (selectedFilter == 'Most sold' && mostSoldProducts.hasValue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _buildProductListWidget(mostSoldProducts),
                      ),

                    if (selectedFilter == 'New products' && newProducts.hasValue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _buildProductListWidget(newProducts),
                      ),
                    if (selectedFilter == 'Discounts' && discountedProducts.hasValue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _buildProductListWidget(discountedProducts),
                      ),
                    const SizedBox(height: 6),
                    const CategoryProductGrid(),
                  ],
                ),
              ],
            ),
          )
        ],
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
            child: Text('Error: ${snapshot.error}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, backgroundColor: Colors.white),),
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
                            /*SingleImageOffer(
                              headTitle: 'EthioCommerce Market | ',
                              subTitle: 'Extra up to Br. 2000 off with coupons',
                              image: category.pictureModel!.imageUrl!,
                              productCategory: category.name ?? 'Unnamed',
                            ),*/
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
                      child: Card(
                        color: Colors.white,
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
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    backgroundColor: Colors.white
                                ),
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
                                    backgroundColor: Colors.white,
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
                                () => context.pushNamed(
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
                                  : Colors.white,
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

//
class ProductCardo extends ConsumerStatefulWidget {
  const ProductCardo({
    super.key,
    required this.product,
    this.onPressed,
    this.width,
  });

  final Product product;
  final VoidCallback? onPressed;
  final double? width;

  @override
  ConsumerState<ProductCardo> createState() => _ProductCardoState();
}

class _ProductCardoState extends ConsumerState<ProductCardo> {
  void addToCart() async {
    _addToCart(ShoppingCartType.shoppingCart);
  }

  void _addToCart(ShoppingCartType cartType) async {
    await ref
        .read(addToCartControllerProvider.notifier)
        .addCartItemFromCatalog(widget.product.id, cartType)
        .then(
          (addProductToCartResponse) => {
        if ((addProductToCartResponse?.success ?? false) && mounted)
          {
            showInSnackBar(
              context,
              (cartType == ShoppingCartType.shoppingCart
                  ? context.locale!.product_add_to_card
                  : context.locale!.product_add_to_wishlist),
              color: Colors.green,
            ),
          }
        else if (mounted)
          {
            context.pushNamed(
              Routes.product.name,
              pathParameters: {'id': widget.product.id.toString()},
            ),
          },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CartItem>>(
      addToCartControllerProvider,
          (_, state) => state.showAlertDialogOnError(context),
    );
    //final
    final state = ref.watch(addToCartControllerProvider);
    //print(widget.product.videoModels?.isNotEmpty);
    const double borderRadius = 12;
    var cardwidth = widget.width ?? MediaQuery.of(context).size.width / 2;

    var productPicture = Stack(
      children: [
        CustomImage(url: widget.product.pictureModels.first.imageUrl ?? ""),
        if (widget.product.markAsNew ?? false) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 0, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.6),
                  offset: const Offset(1, 1),
                  blurRadius: 0.5,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
              child: Text(
                context.locale!.product_new_product_label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ),
        ],
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.favorite_outline_sharp, color: Color(0xffEC692F)),
          ),
        ),
      ],
    );

    return SizedBox(
      width: cardwidth,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: StyleDictionary.mdSysColorPrimary.withOpacity(0.1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        color: Colors.white,
                        child: productPicture,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Star Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: GlobalVariables.secondaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ((widget.product.reviewOverviewModel.totalReviews ??
                            0) >
                            0
                            ? ((widget
                            .product
                            .reviewOverviewModel
                            .ratingSum ??
                            0) /
                            (widget
                                .product
                                .reviewOverviewModel
                                .totalReviews ??
                                1))
                            : 0.0)
                            .toStringAsPrecision(2),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      /* Text(
                        ("(123)"),
                        style: Theme.of(context).textTheme.bodySmall,
                      ), */
                    ],
                  ),

                  // Product Name
                  Text(
                    widget.product.name ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  //bahu added
                  /*Text(
                    widget.product.videoModels?.first.videoUrl ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),*/
                  // Price and Add to Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 2,
                        child: ProductCardPrico(product: widget.product),
                      ),
                      if (!(widget.product.productPrice.disableBuyButton ??
                          false))
                        Flexible(
                          flex: 1,
                          child: CustomIconButton(
                            filled: true,
                            icon: const Icon(Icons.shopping_cart, size: 18),
                            onPressed: state.isLoading ? null : addToCart,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
//
class ProductCardPrico extends StatelessWidget {
  const ProductCardPrico({super.key, required this.product});

  /// Product
  final Product product;

  @override
  Widget build(BuildContext context) {

    final productPrice = product.productPrice;
    final isRental = productPrice.isRental ?? false;
    final isGrouded = product.productType == ProductType.groupedProduct;

    if (productPrice.price != null) {
      String price = productPrice.price!;
      String priceBeforeText = '';
      String priceValue = '';
      String priceAfterText = '';

      if (isRental || isGrouded) {
        int spaceIndex = price.indexOf(" ");

        if (spaceIndex > 0) {
          if (isRental) {
            priceValue = price.substring(0, spaceIndex);
            priceAfterText = price.substring(spaceIndex + 1);
          } else if (isGrouded) {
            priceBeforeText = price.substring(0, spaceIndex);
            priceValue = price.substring(spaceIndex + 1);
          }
        }
      } else {
        priceValue = price;
      }

      return Column(
        children: [
          if (productPrice.oldPrice != null)
            Wrap(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    productPrice.oldPrice!,
                    style: TextStyle(
                      color: Color(0xff595959),
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          if (priceBeforeText.isNotEmpty)
            Wrap(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    priceBeforeText,
                    style: TextStyle(
                      color: GlobalVariables.secondaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          if (priceValue.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                priceValue,
                style: TextStyle(
                  color: GlobalVariables.secondaryColor,
                  fontWeight: FontWeight.w300,
                  fontSize: priceValue.length > 7 ? 17 : 20,
                ),
                maxLines: 2,
                textAlign: TextAlign.left,
                overflow: TextOverflow.fade,
              ),
            ),
          if (priceAfterText.isNotEmpty)
            Wrap(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    priceAfterText,
                    style: TextStyle(
                      color: GlobalVariables.secondaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
    }
}
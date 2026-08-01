
import 'dart:math';
import 'package:nopcommerce_mobile/common_widgets/skeleton_loaders.dart';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_icon_button.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/models/banner_model.dart';
import 'package:nopcommerce_mobile/customize/models/product_model.dart';
import 'package:nopcommerce_mobile/customize/services/api_service.dart';
import 'package:nopcommerce_mobile/customize/services/slide_api_service.dart';
import 'package:nopcommerce_mobile/customize/widgets/custom_carousel.dart';
import 'package:nopcommerce_mobile/customize/widgets/custom_middle_carousel.dart';
import 'package:nopcommerce_mobile/customize/widgets/slides_carousel.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/widgets/single_image_offer.dart';
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
  //added for Sliders
  final ApiServiceSlider _apiServiceSlider = ApiServiceSlider();
  List<BannerCarousel>? carousels;
  String? error;
  //end for sliders
  //added for MostSold, NewProducts, Discount
  //final ApiService apiService = ApiService();
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

  /*Future<void> checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connected to WiFi");
    } else {
      print("No Network Connection");
    }
  }*/

  //
  /*@override
  void initState() {
    super.initState();
    _loadSliders();
  }*/

  Widget _buildProductListWidget(AsyncValue<List<Product>?> valueObj) {
    return AsyncValueWidget<List<Product>?>(
      value: valueObj,
      data:
          (products) =>
      products?.isEmpty ?? true
          ? Text(
            "No Product Found",
            //style: titleFontStyle,
          )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*if (products!.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "No Items Found",
                //style: titleFontStyle,
              ),
            ),*/
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ProductsLayoutLine(
              itemCount: products!.length,
              itemBuilder: (_, index) {
                final producto = products[index];
                return ProductCard2(
                  width: 195,
                  product: producto,
                  onPressed: () => context.pushNamed(
                    Routes.product.name,
                    pathParameters: {'id': producto.id.toString()},
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
  //added for slider

  Future<void> _loadSliders() async {
    try {
      final data = await _apiServiceSlider.getSliders();
      setState(() {
        carousels = data;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        carousels = null;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
     // _loadSliders();
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
              ref.invalidate(categoriesListFutureProvider);
              ref.invalidate(categoryProductMapProvider);
              ref.invalidate(homePageProductsListFutureProvider);
              ref.invalidate(mostSoldProductsListFutureProvider);
              ref.invalidate(newProductsListFutureProvider);
              ref.invalidate(discountProductsListFutureProvider);
              return ref.refresh(categoryProductMapProvider.future);
            },
            child: ListView(
              controller: ScrollController(),
              children: [

                Column(
                  children: [
                    if (categoriesListValue.isLoading)
                      const HomeTopSkeleton()
                    else ...[
                      //if(carousels != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: CustomCarouselSlider(),
                      ),
                      TopCategories(categoriesListValue),
                      FilterRow(onFilterSelected: updateProductList),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical:5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //if(carousels != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: CustomCarouselMiddleSlider(),
                              ),
                            /*SingleImageOffer(
                              headTitle: 'EthioCommerce Market | ',
                              subTitle: 'Extra up to Br. 2000 off with coupons',
                              image: "https://postgebeya.ethio.post/images/thumbs/0002247_web%20banner1-100%20(3).jpeg",
                              productCategory:'Unnamed',
                            ),*/
                          ],
                        ),
                      ),

                    ],
                    if (selectedFilter == 'All')
                      const CategoryProductGrid(),
                    if (selectedFilter == 'Trending')
                      //const CategoryProductGrid(),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: ProductsLine(
                          valueObj: productsListValue,
                          title: ' ',
                        ),
                      ),
                    if (selectedFilter == 'Bestsellers' && mostSoldProducts.hasValue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _buildProductListWidget(mostSoldProducts),
                      ),

                    if (selectedFilter == 'Newest' && newProducts.hasValue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _buildProductListWidget(newProducts),
                      ),
                    if (selectedFilter == 'Cheapest' && discountedProducts.hasValue)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: _buildProductListWidget(discountedProducts),
                      ),
                    const SizedBox(height: 6),
                    //const CategoryProductGrid(),
                    const SizedBox(height: 60),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryMapAsync = ref.watch(categoryProductMapProvider);

    return categoryMapAsync.when(
      loading: () => const ProductSectionSkeleton(),
      error: (_, __) => const Padding(
        padding: EdgeInsets.all(16),
        child: Icon(Icons.wifi_off_rounded, size: 48, color: Colors.blue),
      ),
      data: (categoryMap) {
        final entries = categoryMap.entries.toList();
        final midIndex = entries.length ~/ 2;
        return Column(
          children: entries.asMap().entries.map((indexedEntry) {
                final index = indexedEntry.key;
                final category = indexedEntry.value.key;
                final products = indexedEntry.value.value;

                final showBanner = category.pictureModel?.imageUrl != null &&
                    (index == 0 || index == midIndex);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 0),
                    if (showBanner)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical:5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*SingleImageOffer(
                              headTitle: 'EthioCommerce Market | ',
                              subTitle: 'Extra up to Br. 2000 off with coupons',
                              image: "https://postgebeya.ethio.post/images/thumbs/0002247_web%20banner1-100%20(3).jpeg",
                              productCategory: category.name ?? 'Unnamed',
                            ),*/
                          ],
                        ),
                      ),
                    if (products.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2C2E7B), Color(0xFF3A3D9E)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x302C2E7B),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5AD00),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  category.name ?? 'Unnamed',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.pushNamed(
                                  Routes.category.name,
                                  pathParameters: {'id': category.id.toString()},
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5AD00),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'See All',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (products.isNotEmpty)
                      Builder(builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        // Show 2 full cards + peek of 3rd (≈30% visible)
                        final cardWidth = (screenWidth - 32) / 2.25;
                        // image is 1:1 ratio + 120px for name/price/button
                        final cardHeight = cardWidth + 120;
                        return SizedBox(
                          height: cardHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            clipBehavior: Clip.none,
                            itemCount: products.length,
                            itemBuilder: (context, i) {
                              final product = products[i];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: i < products.length - 1 ? 10 : 0,
                                ),
                                child: ProductCard(
                                  width: cardWidth,
                                  product: product,
                                  onPressed: () => context.pushNamed(
                                    Routes.product.name,
                                    pathParameters: {'id': product.id!.toString()},
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  ],
                );
              }).toList(),
        );
      },
    );
  }
}

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
    {'label': 'Trending', 'icon': Icons.trending_up_outlined},
    {'label': 'Bestsellers', 'icon': Icons.trending_up},
    {'label': 'Newest', 'icon': Icons.new_releases},
    {'label': 'Cheapest', 'icon': Icons.local_offer},
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


    return SizedBox(
      width: cardwidth,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: StyleDictionary.mdSysColorPrimary.withOpacity(0.2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Image
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        color: Colors.white,
                        child: CustomImage(url: widget.product.pictureModels.first.imageUrl ?? ""),
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

class ColorLoader3 extends StatefulWidget {
  final double radius;
  final double dotRadius;

  ColorLoader3({this.radius = 30.0, this.dotRadius = 3.0});

  @override
  _ColorLoader3State createState() => _ColorLoader3State();
}

class _ColorLoader3State extends State<ColorLoader3>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation_rotation;
  late Animation<double> animation_radius_in;
  late Animation<double> animation_radius_out;
  late AnimationController controller;

  late double radius;
  late double dotRadius;

  @override
  void initState() {
    super.initState();

    radius = widget.radius;
    dotRadius = widget.dotRadius;

    print(dotRadius);

    controller = AnimationController(
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: const Duration(milliseconds: 3000),
        vsync: this);

    animation_rotation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    animation_radius_in = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.75, 1.0, curve: Curves.elasticIn),
      ),
    );

    animation_radius_out = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.25, curve: Curves.elasticOut),
      ),
    );

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0)
          radius = widget.radius * animation_radius_in.value;
        else if (controller.value >= 0.0 && controller.value <= 0.25)
          radius = widget.radius * animation_radius_out.value;
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {}
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      //color: Colors.black12,
      child: new Center(
        child: new RotationTransition(

          turns: animation_rotation,
          child: new Container(
            //color: Colors.limeAccent,
            child: new Center(
              child: Stack(
                children: <Widget>[
                  new Transform.translate(
                    offset: Offset(0.0, 0.0),
                    child: Dot(
                      radius: radius,
                      color: Colors.black12,
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.amber,
                    ),
                    offset: Offset(
                      radius * cos(0.0),
                      radius * sin(0.0),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.deepOrangeAccent,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 1 * pi / 4),
                      radius * sin(0.0 + 1 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.pinkAccent,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 2 * pi / 4),
                      radius * sin(0.0 + 2 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.purple,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 3 * pi / 4),
                      radius * sin(0.0 + 3 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.yellow,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 4 * pi / 4),
                      radius * sin(0.0 + 4 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.lightGreen,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 5 * pi / 4),
                      radius * sin(0.0 + 5 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.orangeAccent,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 6 * pi / 4),
                      radius * sin(0.0 + 6 * pi / 4),
                    ),
                  ),
                  new Transform.translate(
                    child: Dot(
                      radius: dotRadius,
                      color: Colors.blueAccent,
                    ),
                    offset: Offset(
                      radius * cos(0.0 + 7 * pi / 4),
                      radius * sin(0.0 + 7 * pi / 4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {

    controller.dispose();
    super.dispose();
  }
}

class Dot extends StatelessWidget {
  final double? radius;
  final Color? color;

  Dot({this.radius, this.color});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),

      ),
    );
  }
}
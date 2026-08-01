import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nopcommerce_mobile/common_widgets/applied_filters.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/catalog_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/filter/filter_utility.dart';
import 'package:nopcommerce_mobile/features/products/presentation/products_paged_grid.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/product_search.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class CategoryDetailsScreen extends ConsumerStatefulWidget {
  const CategoryDetailsScreen({super.key, required this.categoryId});
  final int categoryId;

  @override
  ConsumerState<CategoryDetailsScreen> createState() =>
      _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState
    extends ConsumerState<CategoryDetailsScreen> {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  final PagingController<int, ProductOverviewModelDto> _pagingController =
      PagingController(firstPageKey: 1);

  final CatalogProductsCommandDtoBuilder _filterBuilder =
      CatalogProductsCommandDtoBuilder();

  String _title = '';
  int _totalItems = 0;
  BuiltList<SubCategoryModelDto>? _subCategories =
      BuiltList<SubCategoryModelDto>();
  CategoryModelDto? _category;

  @override
  void initState() {
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final catalogRepository = ref.watch(catalogRepositoryProvider);
      _filterBuilder.pageNumber = pageKey;

      final newItems = await catalogRepository.getCategoryById(
        categoryId: widget.categoryId,
        pageParams: _filterBuilder,
      );

      final isLastPage =
          (newItems?.catalogProductsModel?.totalPages ?? 1) <=
          (newItems?.catalogProductsModel?.pageNumber ?? 1);

      final list =
          newItems?.catalogProductsModel?.products?.toList() ?? [];

      if (isLastPage) {
        _pagingController.appendLastPage(list);
      } else {
        _pagingController.appendPage(list, pageKey + 1);
      }

      setState(() {
        _subCategories = newItems?.subCategories;
        _category = newItems;
        _title = newItems?.name ?? '';
        _totalItems =
            newItems?.catalogProductsModel?.totalItems ?? 0;
      });
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _category?.pictureModel?.imageUrl ?? '';
    final hasImage = imageUrl.isNotEmpty;
    final hasSubCats =
        _subCategories != null && _subCategories!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      body: RefreshIndicator(
        color: _blue,
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: CustomScrollView(
          slivers: [
            // ── Collapsing hero app bar ──────────────────────────────
            SliverAppBar(
              backgroundColor: _blue,
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: hasImage ? 240 : 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const ProductSearch(),
                ),
                if (hasSortOption(_category?.catalogProductsModel))
                  Container(
                    margin:
                        const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.sort_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => sortOptionsBuilder(
                        context: context,
                        catalogProducts:
                            _category?.catalogProductsModel,
                        pagingController: _pagingController,
                        filterBuilder: _filterBuilder,
                      ),
                    ),
                  ),
                Container(
                  margin:
                      const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => filterOptionsBuilder(
                      context: context,
                      catalogProducts: _category?.catalogProductsModel,
                      filterBuilder: _filterBuilder,
                      pagingController: _pagingController,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.fromLTRB(56, 0, 56, 14),
                centerTitle: true,
                title: Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomImage(
                            url: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          // gradient overlay so title is readable
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xCC2C2E7B),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.4, 1.0],
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
            ),

            // ── Sub-categories horizontal scroll ─────────────────────
            if (hasSubCats)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _orange,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SUB-CATEGORIES',
                            style: TextStyle(
                              color: _blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _subCategories!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final cat = _subCategories![i];
                            return GestureDetector(
                              onTap: () => context.pushNamed(
                                Routes.category.name,
                                pathParameters: {
                                  'id': cat.id!.toString()
                                },
                              ),
                              child: SizedBox(
                                width: 90,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _blue.withValues(
                                                alpha: 0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        child: cat.pictureModel
                                                    ?.imageUrl !=
                                                null
                                            ? CustomImage(
                                                url: cat.pictureModel!
                                                    .imageUrl!,
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(
                                                Icons.category_rounded,
                                                color: _blue.withValues(
                                                    alpha: 0.4),
                                                size: 30,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat.name ?? '',
                                      style: const TextStyle(
                                        color: _blue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Applied filters ──────────────────────────────────────
            if (_category?.catalogProductsModel != null)
              SliverToBoxAdapter(
                child: AppliedFilters(
                  catalogProductsModel:
                      _category!.catalogProductsModel!,
                  filterBuilder: _filterBuilder,
                  pagingController: _pagingController,
                ),
              ),

            // ── Items count + sort bar ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    if (_totalItems > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_totalItems ${_totalItems == 1 ? 'item' : 'items'}',
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (hasSortOption(_category?.catalogProductsModel))
                      GestureDetector(
                        onTap: () => sortOptionsBuilder(
                          context: context,
                          catalogProducts:
                              _category?.catalogProductsModel,
                          pagingController: _pagingController,
                          filterBuilder: _filterBuilder,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.sort_rounded,
                                  color: Colors.grey.shade600,
                                  size: 15),
                              const SizedBox(width: 5),
                              Text(
                                'Sort',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Product grid ─────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                12, 0, 12,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              sliver:
                  ProductsLayoutPagedGrid(pagingController: _pagingController),
            ),
          ],
        ),
      ),
    );
  }
}

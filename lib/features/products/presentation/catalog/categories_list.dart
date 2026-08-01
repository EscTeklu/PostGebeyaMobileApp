import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/category_list_item.dart';

class CategoriesList extends StatelessWidget {
  const CategoriesList(this.valueObj, {super.key});

  final AsyncValue<BuiltList<CategorySimpleModelDto>?> valueObj;

  @override
  Widget build(BuildContext context) {
    return AsyncValueWidget<BuiltList<CategorySimpleModelDto>?>(
      value: valueObj,
      data: (categories) => categories?.isEmpty ?? true
          ? const SizedBox.shrink()
          : CategoriesLayoutList(
              itemCount: categories!.length,
              itemBuilder: (_, index) {
                final category = categories[index];
                return CategoryListItem(
                  categoryId: category.id!,
                  categoryName: category.name,
                  categoryPictureUrl: category.pictureModel?.imageUrl,
                );
              },
            ),
    );
  }
}

class CategoriesLayoutList extends StatelessWidget {
  const CategoriesLayoutList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 155,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

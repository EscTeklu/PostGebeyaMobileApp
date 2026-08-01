import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/widgets/single_top_category_item.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class TopCategories extends StatelessWidget {
  const TopCategories(this.valueObj, {super.key});

  final AsyncValue<BuiltList<CategorySimpleModelDto>?> valueObj;

  @override
  Widget build(BuildContext context) {
    return AsyncValueWidget<BuiltList<CategorySimpleModelDto>?>(
      value: valueObj,
      data:
          (categories) =>
              categories?.isEmpty ?? true
                  ? Container()
                  : Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: GlobalVariables.bgGradient,
                    ),
                    child: Center(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories!.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return GestureDetector(
                            onTap:
                                () => context.pushNamed(
                                  Routes.category.name,
                                  pathParameters: {'id': cat.id.toString()},
                                ),
                            //context, GlobalVariables.categoryImages[index]['title']!),
                            child: SingleTopCategoryItem(
                              title:
                                  cat.name!, // GlobalVariables.categoryImages[index]['title']!,
                              image:
                                  cat
                                      .pictureModel!
                                      .imageUrl!, //.categoryImages[index]['image']!,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
    );
  }

}

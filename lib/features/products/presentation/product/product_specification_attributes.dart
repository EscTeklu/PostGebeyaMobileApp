import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class ProductSpecificationAttributes extends StatelessWidget {
  const ProductSpecificationAttributes({super.key, required this.groups});

  final BuiltList<ProductSpecificationAttributeGroupModelDto> groups;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        const SizedBox(height: 10),
        Text(
          context.locale!.product_spec,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < groups.length; i++)
          for (int j = 0; j < (groups[i].attributes?.length ?? 0); j++)
            SpecificationAttributeItem(attribute: groups[i].attributes![j]),
      ],
    );
  }
}

class SpecificationAttributeItem extends StatelessWidget {
  const SpecificationAttributeItem({super.key, required this.attribute});

  final ProductSpecificationAttributeModelDto attribute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            attribute.name ?? '',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          flex: 7,
          child: HtmlWidget(
            attribute.values?.first.valueRaw ?? '',
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

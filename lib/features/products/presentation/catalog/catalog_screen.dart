import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/product_search.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/catalog_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/categories_list.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/vendors_grid.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesListValue = ref.watch(categoriesListFutureProvider);

    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.accentColor,
        title: Text(
          context.locale!.catalog,
          style: TextStyle(color: Colors.white),
        ),
        actions: const [ProductSearch()],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg5.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          ListView(
            controller: ScrollController(),
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: CategoriesList(categoriesListValue),
              ),
              //const ManufacturersGrid(),
              const VendorGrid(),
            ],
          ),
        ],
      )
    );
  }
}

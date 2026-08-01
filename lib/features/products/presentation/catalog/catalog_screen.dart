import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/product_search.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/catalog_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/categories_list.dart';
import 'package:nopcommerce_mobile/features/products/presentation/catalog/vendors_grid.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesListValue = ref.watch(categoriesListFutureProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.catalog,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        actions: const [ProductSearch()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Browse Categories',
                style: TextStyle(
                  color: _blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CategoriesList(categoriesListValue),
          const SizedBox(height: 24),
          const VendorGrid(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_details_grouped.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product/product_details_simple.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product_providers.dart';
import 'package:nopcommerce_mobile/utils/base_nop_state.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});
  final int productId;

  static const _blue = Color(0xFF2C2E7B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productValue = ref.watch(productProvider(productId));

    ref.listen<BaseNopState>(
      downloadControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return AsyncValueWidget<ProductDetailsModelDto?>(
      value: productValue,
      data: (product) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: _blue,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            product?.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.share_outlined,
                    color: Colors.white, size: 20),
                onPressed: () => Share.share(
                  '${AppConstants.storeUrl}${product?.seName ?? ''}',
                ),
              ),
            ),
          ],
        ),
        body: InkWell(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: RefreshIndicator(
            color: _blue,
            onRefresh: () => ref.refresh(productProvider(productId).future),
            child: product != null
                ? product.productType == ProductType.simpleProduct
                    ? ProductDetailsSimple(product: product)
                    : ProductDetailsGrouped(product: product)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

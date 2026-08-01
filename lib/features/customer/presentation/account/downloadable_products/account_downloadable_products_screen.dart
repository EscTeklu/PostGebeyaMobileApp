import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/alert_dialogs.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/items_not_found.dart';
import 'package:nopcommerce_mobile/common_widgets/text_link.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/products/presentation/product_providers.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/base_nop_state.dart';
import 'package:nopcommerce_mobile/utils/common_utility.dart';
import 'package:nopcommerce_mobile/utils/date_format_provider.dart';

const _blue = Color(0xFF2C2E7B);
const _orange = Color(0xFFF5AD00);
const _bg = Color(0xFFF4F5FB);

class AccountDownloadableProductsScreen extends ConsumerWidget {
  const AccountDownloadableProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadableProducts = ref.watch(
      customerDownloadableProductsProvider,
    );

    return AsyncValueWidget<CustomerDownloadableProductsModelDto?>(
      value: downloadableProducts,
      data: (model) => AccountDownloadableProductsContents(
        context: context,
        downloadableProducts: model ?? CustomerDownloadableProductsModelDto(),
      ),
    );
  }
}

class AccountDownloadableProductsContents extends ConsumerWidget {
  const AccountDownloadableProductsContents({
    super.key,
    required this.context,
    required this.downloadableProducts,
  });

  final CustomerDownloadableProductsModelDto downloadableProducts;
  final BuildContext context;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countItems = downloadableProducts.items?.length ?? 0;
    final dateTimeProvider = ref.watch(dateTimeFormatterProvider);

    ref.listen<BaseNopState>(
      downloadControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_downloadable_products,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: countItems > 0
          ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: countItems,
              itemBuilder: (context, index) {
                final product = downloadableProducts.items![index];
                final downloadId = product.downloadId ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _blue.withValues(alpha: 0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextLink(
                                  label: product.productName ?? '',
                                  onTap: () => context.pushNamed(
                                    Routes.product.name,
                                    pathParameters: {
                                      'id': product.productId.toString(),
                                    },
                                  ),
                                  textStyle: const TextStyle(
                                    color: _blue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.locale!
                                        .account_downloadable_products_order_number
                                        .format([product.orderId ?? 0]),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        context.locale!
                                            .account_downloadable_products_order_date,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        dateTimeProvider.format(
                                          product.createdOn!,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _blue,
                                    side: const BorderSide(color: _blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.receipt_long_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    context.locale!
                                        .account_downloadable_products_button_order_details,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () => context.pushNamed(
                                    Routes.orderDetails.name,
                                    pathParameters: {
                                      'id': product.orderId.toString(),
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: downloadId == 0
                                        ? Colors.grey.shade300
                                        : _orange,
                                    foregroundColor: downloadId == 0
                                        ? Colors.grey.shade500
                                        : Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    downloadId == 0
                                        ? context.locale!
                                            .account_downloadable_products_button_download_not
                                        : context.locale!
                                            .account_downloadable_products_button_download,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onPressed: downloadId == 0
                                      ? null
                                      : () => _download(ref, product, context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : ItemsNotFound(
              text: context.locale!.account_downloadable_products_no_found,
            ),
    );
  }

  void _download(
    WidgetRef ref,
    DownloadableProductsModelDto product,
    BuildContext ctx,
  ) {
    final orderItemGuid = product.orderItemGuid;
    if (orderItemGuid == null) {
      return;
    }

    final productsRepository = ref.read(productsRepositoryProvider);
    productsRepository
        .getProductDetails(product.productId ?? 0, null)
        .then(
          (value) => _handleDownload(ref, orderItemGuid, value, ctx),
          onError: (e) {
            if (ctx.mounted) {
              showInSnackBar(ctx, e.toString());
            }
          },
        );
  }

  FutureOr _handleDownload(
    WidgetRef ref,
    String orderItemGuid,
    ProductDetailsModelDto? value,
    BuildContext ctx,
  ) {
    if (value?.hasUserAgreement ?? false) {
      showAlertDialog(
        context: ctx,
        title: context.locale!.account_downloadable_products_user_agreement,
        content: value?.userAgreementText ?? '',
        cancelActionText: context
            .locale!
            .account_downloadable_products_user_agreement_donot_agree,
        defaultActionText:
            context.locale!.account_downloadable_products_user_agreement_agree,
      ).then((agreed) {
        if (ctx.mounted) {
          _downloadFile(ref, orderItemGuid, agreed, ctx);
        }
      });
    } else {
      _downloadFile(ref, orderItemGuid, false, ctx);
    }
  }

  void _downloadFile(
    WidgetRef ref,
    String orderItemGuid,
    bool? agreed,
    BuildContext ctx,
  ) {
    final controller = ref.read(downloadControllerProvider.notifier);
    controller.download(orderItemGuid, agreed ?? false).then((value) {
      if (value == null || !ctx.mounted) {
        return;
      }
      showInSnackBar(
        ctx,
        value
            ? context.locale!.account_downloadable_products_message_completed
            : context.locale!.account_downloadable_products_message_failed,
      );
    });
  }
}

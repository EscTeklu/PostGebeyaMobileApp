import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/items_not_found.dart';
import 'package:nopcommerce_mobile/features/app/repository_provider.dart';
import 'package:nopcommerce_mobile/features/customer/data/customer_repository.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/back_in_stock/subscription_card.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/async_value_ui.dart';

const _blue = Color(0xFF2C2E7B);
const _bg = Color(0xFFF4F5FB);

class AccountBackInStockScreen extends ConsumerWidget {
  const AccountBackInStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backInStockSubscriptions = ref.watch(customerBackInStockProvider);

    return AsyncValueWidget<CustomerBackInStockSubscriptionsModelDto?>(
      value: backInStockSubscriptions,
      data: (model) => AccountBackInStockContents(
        backInStockSubscriptions:
            model ?? CustomerBackInStockSubscriptionsModelDto(),
      ),
    );
  }
}

class AccountBackInStockContents extends ConsumerStatefulWidget {
  const AccountBackInStockContents({
    super.key,
    required this.backInStockSubscriptions,
  });

  final CustomerBackInStockSubscriptionsModelDto backInStockSubscriptions;

  @override
  ConsumerState<AccountBackInStockContents> createState() =>
      _AccountBackInStockContentsState();
}

class _AccountBackInStockContentsState
    extends ConsumerState<AccountBackInStockContents> {
  final PagingController<int, BackInStockSubscriptionModelDto>
  _pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final customerRepository = ref.watch(
        getRepositoryProvider(() => CustomerRepository()),
      );

      final newItems = await customerRepository.getCurrentCustomerBackInStock(
        pageKey,
      );

      final isLastPage =
          (newItems.pagerModel?.totalPages ?? 1) <=
          (newItems.pagerModel?.currentPage ?? 1);

      if (isLastPage) {
        _pagingController.appendLastPage(
          newItems.subscriptions?.asList() ??
              <BackInStockSubscriptionModelDto>[],
        );
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(
          newItems.subscriptions?.asList() ??
              <BackInStockSubscriptionModelDto>[],
          nextPageKey,
        );
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      customerBackInStockControllerProvider.select((state) => state.value),
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_back_in_stock_subscriptions,
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
      body: PagedListView<int, BackInStockSubscriptionModelDto>(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        pagingController: _pagingController,
        builderDelegate:
            PagedChildBuilderDelegate<BackInStockSubscriptionModelDto>(
              itemBuilder: (context, item, index) => Padding(
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
                  child: BackInStockSubscriptionCard(item),
                ),
              ),
              noItemsFoundIndicatorBuilder: (context) => ItemsNotFound(
                text: context.locale!.account_back_in_stock_subscriptions_no_found,
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

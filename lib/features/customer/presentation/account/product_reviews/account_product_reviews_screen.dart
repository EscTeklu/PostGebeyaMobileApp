import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nopcommerce_mobile/common_widgets/items_not_found.dart';
import 'package:nopcommerce_mobile/features/app/repository_provider.dart';
import 'package:nopcommerce_mobile/features/customer/data/customer_repository.dart';
import 'package:nopcommerce_mobile/features/reviews/presentation/customer_review_card.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

const _blue = Color(0xFF2C2E7B);
const _bg = Color(0xFFF4F5FB);

class AccountProductReviewsScreen extends StatelessWidget {
  const AccountProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_reviews,
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
      body: const _ReviewListView(),
    );
  }
}

class _ReviewListView extends ConsumerStatefulWidget {
  const _ReviewListView();

  @override
  ConsumerState<_ReviewListView> createState() => _ReviewListViewState();
}

class _ReviewListViewState extends ConsumerState<_ReviewListView> {
  final PagingController<int, CustomerProductReviewModelDto> _pagingController =
      PagingController(firstPageKey: 1);

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

      final newItems =
          await customerRepository.getCurrentCustomerProductReviews(pageKey);

      final isLastPage =
          (newItems.pagerModel?.totalPages ?? 1) <=
          (newItems.pagerModel?.currentPage ?? 1);

      if (isLastPage) {
        _pagingController.appendLastPage(
          newItems.productReviews?.asList() ??
              <CustomerProductReviewModelDto>[],
        );
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(
          newItems.productReviews?.asList() ??
              <CustomerProductReviewModelDto>[],
          nextPageKey,
        );
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, CustomerProductReviewModelDto>(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<CustomerProductReviewModelDto>(
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
            child: CustomerProductReviewCard(item),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) =>
            ItemsNotFound(text: context.locale!.account_reviews_no_found),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

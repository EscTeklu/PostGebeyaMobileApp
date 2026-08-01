import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/items_not_found.dart';
import 'package:nopcommerce_mobile/features/app/repository_provider.dart';
import 'package:nopcommerce_mobile/features/customer/data/customer_repository.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/reward_points/account_reward_points_balance.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/reward_points/account_reward_points_card.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

const _blue = Color(0xFF2C2E7B);
const _orange = Color(0xFFF5AD00);
const _bg = Color(0xFFF4F5FB);

class AccountRewardPointsScreen extends ConsumerWidget {
  const AccountRewardPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardPoints = ref.watch(customerRewardPointsProvider(1));

    return AsyncValueWidget<CustomerRewardPointsModelDto?>(
      value: rewardPoints,
      data: (rewardPoints) => AccountRewardPointsContents(
        rewardPoints: rewardPoints ?? CustomerRewardPointsModelDto(),
      ),
    );
  }
}

class AccountRewardPointsContents extends ConsumerWidget {
  const AccountRewardPointsContents({super.key, required this.rewardPoints});

  final CustomerRewardPointsModelDto rewardPoints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.account_reward_points,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Balance summary card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2E7B), Color(0xFF3F42A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: _orange,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.locale!.account_reward_points,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RewardPointsBalance(rewardPoints: rewardPoints),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // History section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
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
                Text(
                  context.locale!.account_reward_points_history.toUpperCase(),
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          // Paged history list
          const Expanded(child: RewardPointsHistory()),
        ],
      ),
    );
  }
}

class RewardPointsHistory extends ConsumerStatefulWidget {
  const RewardPointsHistory({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RewardPointsHistoryState();
}

class _RewardPointsHistoryState extends ConsumerState<RewardPointsHistory> {
  final PagingController<int, RewardPointsHistoryModelDto> _pagingController =
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

      final newItems = await customerRepository.getCurrentCustomerRewardPoints(
        pageKey,
      );

      final isLastPage =
          (newItems.pagerModel?.totalPages ?? 1) <=
          (newItems.pagerModel?.currentPage ?? 1);

      if (isLastPage) {
        _pagingController.appendLastPage(
          newItems.rewardPoints?.asList() ?? <RewardPointsHistoryModelDto>[],
        );
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(
          newItems.rewardPoints?.asList() ?? <RewardPointsHistoryModelDto>[],
          nextPageKey,
        );
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, RewardPointsHistoryModelDto>(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<RewardPointsHistoryModelDto>(
        itemBuilder: (context, item, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
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
            child: RewardPointsCard(item),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => ItemsNotFound(
          text: context.locale!.account_reward_points_history_no_found,
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

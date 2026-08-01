import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/utils/date_format_provider.dart';

const _blue = Color(0xFF2C2E7B);

class RewardPointsCard extends ConsumerWidget {
  const RewardPointsCard(this.item, {super.key});
  final RewardPointsHistoryModelDto item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTimeProvider = ref.watch(dateTimeFormatterProvider);
    final isPositive = (item.points ?? 0) > 0;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.add_rounded : Icons.remove_rounded,
              color: isPositive ? Colors.green.shade600 : Colors.red.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.createdOn != null)
                  Text(
                    dateTimeProvider.format(item.createdOn!),
                    style: const TextStyle(
                      color: _blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (item.message?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.message!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
                if (item.endDate != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${context.locale!.account_reward_points_history_end} ${dateTimeProvider.format(item.endDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Points + balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${item.points ?? 0}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isPositive ? Colors.green.shade600 : Colors.red.shade400,
                ),
              ),
              if (item.pointsBalance?.isNotEmpty ?? false)
                Text(
                  item.pointsBalance!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

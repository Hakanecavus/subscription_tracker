import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subscription_tracker/core/constants/routes.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';
import 'package:subscription_tracker/presentation/providers/core_providers.dart';
import 'package:subscription_tracker/presentation/widgets/common_widgets.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(subscriptionByIdProvider(subscriptionId));
    final l = ref.watch(appLocalizationsProvider);
    final dateFormat = DateFormat.yMMMMd(l.localeCode);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: subAsync.maybeWhen(
          data: (sub) => sub == null ? [] : [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context, ref, sub, l),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                context.push('${AppRoutes.subscriptions}/edit/${sub.id}');
              },
            ),
            const SizedBox(width: 8),
          ],
          orElse: () => [],
        ),
      ),
      body: SafeArea(
        child: subAsync.when(
          data: (sub) {
            if (sub == null) {
              return Center(child: Text(l.tr('not_found')));
            }

            final nextPaymentDays = sub.nextBillingDate.difference(DateTime.now()).inDays;

            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(sub.iconUrl),
                      size: 40,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(sub.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Center(
                  child: Text(
                    sub.billingCycle.name.toUpperCase(),
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${sub.currency} ${sub.amount.toStringAsFixed(2)} / ${sub.billingCycle.name.toLowerCase()}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 32),
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Next Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(dateFormat.format(sub.nextBillingDate)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            nextPaymentDays == 0 
                              ? 'Today' 
                              : nextPaymentDays < 0 
                                ? 'Overdue' 
                                : 'in $nextPaymentDays days',
                            style: TextStyle(
                              color: nextPaymentDays <= 3 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(Icons.circle, size: 12, color: nextPaymentDays <= 3 ? Theme.of(context).colorScheme.error : Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 8),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // For now, just show the last payment (mocking history)
                      _HistoryRow(
                        date: dateFormat.format(sub.startDate), 
                        amount: '${sub.currency} ${sub.amount.toStringAsFixed(2)}',
                        isFirst: true,
                      ),
                    ],
                  ),
                ),
                if (sub.notes != null && sub.notes!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Text(sub.notes!),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Subscription sub, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.tr('delete_subscription')),
        content: Text(l.trArgs('delete_confirm', [sub.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final repository = ref.read(subscriptionRepositoryProvider);
              await repository.delete(sub.id);
              ref.invalidate(allSubscriptionsProvider);
              ref.invalidate(totalMonthlyCostProvider);
              if (context.mounted) {
                context.pop(); // Go back from detail
              }
            },
            child: Text(l.tr('delete'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? iconUrl) {
    return Icons.subscriptions;
  }
}

class _HistoryRow extends StatelessWidget {
  final String date;
  final String amount;
  final bool isFirst;

  const _HistoryRow({required this.date, required this.amount, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

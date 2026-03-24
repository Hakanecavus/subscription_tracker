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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tr('my_subscriptions')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // ignore: unused_result
            ref.refresh(allSubscriptionsProvider);
            // ignore: unused_result
            ref.refresh(totalMonthlyCostProvider);
            // ignore: unused_result
            ref.refresh(dueSubscriptionsProvider(7));
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: const [
              _MonthlyCostSection(),
              SizedBox(height: 24),
              _UpcomingPaymentsSection(),
              SizedBox(height: 24),
              _AllSubscriptionsSection(),
              SizedBox(height: 80), // Fab padding
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.addSubscription);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MonthlyCostSection extends ConsumerWidget {
  const _MonthlyCostSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyCostAsync = ref.watch(totalMonthlyCostProvider);
    final l = ref.watch(appLocalizationsProvider);

    return monthlyCostAsync.when(
      data: (cost) => StatCard(
        title: l.tr('monthly_total'),
        value: NumberFormat.currency(symbol: '\$').format(cost),
        iconOrTrend: const Icon(Icons.account_balance_wallet, color: Colors.grey),
      ),
      loading: () => const SkeletonLoader(height: 100),
      error: (e, s) => AppCard(
        child: Text('Error loading cost: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
    );
  }
}

class _UpcomingPaymentsSection extends ConsumerWidget {
  const _UpcomingPaymentsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(dueSubscriptionsProvider(7));
    final l = ref.watch(appLocalizationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l.tr('upcoming')} (7 ${l.tr('days')})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        upcomingAsync.when(
          data: (subs) {
            if (subs.isEmpty) {
              return AppCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(l.tr('no_upcoming')),
                  ),
                ),
              );
            }
            return Column(
              children: subs.map((sub) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SubscriptionListItem(sub: sub, isUpcoming: true),
              )).toList(),
            );
          },
          loading: () => const SkeletonLoader(height: 80),
          error: (e, s) => Text('Error loading upcoming: $e'),
        ),
      ],
    );
  }
}

class _AllSubscriptionsSection extends ConsumerWidget {
  const _AllSubscriptionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSubsAsync = ref.watch(allSubscriptionsProvider);
    final l = ref.watch(appLocalizationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.tr('all_subscriptions'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.push(AppRoutes.addSubscription);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        allSubsAsync.when(
          data: (subs) {
            if (subs.isEmpty) {
              return const EmptyStateWidget(message: 'No subscriptions yet', icon: Icons.subscriptions_outlined);
            }
            return Column(
              children: subs.map((sub) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SubscriptionListItem(sub: sub),
              )).toList(),
            );
          },
          loading: () => const Column(
            children: [
              SkeletonLoader(height: 72),
              SizedBox(height: 8),
              SkeletonLoader(height: 72),
            ],
          ),
          error: (e, s) => Text('Error loading subscriptions: $e'),
        ),
      ],
    );
  }
}


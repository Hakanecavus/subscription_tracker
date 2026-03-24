import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:subscription_tracker/core/constants/routes.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';
import 'package:subscription_tracker/presentation/widgets/common_widgets.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(filteredSubscriptionsProvider);
    final l = ref.watch(appLocalizationsProvider);
    final searchQuery = ref.watch(subscriptionSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tr('subscriptions')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                labelText: l.tr('search_subscriptions'),
                prefixIcon: const Icon(Icons.search),
                onChanged: (val) {
                  ref.read(subscriptionSearchProvider.notifier).state = val;
                },
              ),
            ),
            Expanded(
              child: subscriptionsAsync.when(
                data: (subs) {
                  if (subs.isEmpty) {
                    return Center(
                      child: EmptyStateWidget(
                        message: searchQuery.isEmpty ? l.tr('no_subscriptions') : l.tr('no_matches'),
                        icon: Icons.subscriptions_outlined,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: subs.length,
                    itemBuilder: (context, index) {
                      final sub = subs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SubscriptionListItem(sub: sub),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addSubscription),
        child: const Icon(Icons.add),
      ),
    );
  }
}

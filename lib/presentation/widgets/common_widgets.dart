import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:subscription_tracker/core/constants/routes.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';
import 'package:subscription_tracker/presentation/providers/core_providers.dart';

/// Base widget for common UI patterns
abstract class BaseWidget extends ConsumerWidget {
  const BaseWidget({super.key});

  Widget buildLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => onRetry(), child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget buildEmpty(BuildContext context, {String? message, IconData? icon}) {
    return EmptyStateWidget(
      message: message ?? 'No items found',
      icon: icon ?? Icons.inbox_outlined,
    );
  }

  void onRetry();
}

/// Standalone Empty State
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Reusable card widget
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// Stat Card widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? iconOrTrend;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.iconOrTrend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (iconOrTrend != null) iconOrTrend!,
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable button widget
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isGhost;
  final bool isDanger;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isGhost = false,
    this.isDanger = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          );

    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = isDanger ? colorScheme.error : colorScheme.primary;

    if (isGhost) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(0, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: child,
    );
  }
}

/// Custom Text Field
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
    );
  }
}

/// Swipeable List Item
class SwipeableListItem extends StatelessWidget {
  final String id;
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SwipeableListItem({
    super.key,
    required this.id,
    required this.child,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(id),
      background: Container(
        color: colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.edit, color: colorScheme.onPrimary),
      ),
      secondaryBackground: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false; // Don't dismiss for edit
        } else if (direction == DismissDirection.endToStart) {
          if (onDelete == null) return false;
          // You could show a confirmation dialog here
          onDelete?.call();
          return false; // Don't dismiss, let the delete handler manage it
        }
        return false;
      },
      child: child,
    );
  }
}

/// Skeleton Loader
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 72,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    // In a full app, you might use the shimmer package.
    // We use an animated container for a simple effect here since the package isn't listed.
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

/// Generic Subscription List Item with Swiping support
class SubscriptionListItem extends ConsumerWidget {
  final Subscription sub;
  final bool isUpcoming;
  final VoidCallback? onTap;

  const SubscriptionListItem({
    super.key,
    required this.sub,
    this.isUpcoming = false,
    this.onTap,
  });

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Subscription subscription) {
    final l = ref.read(appLocalizationsProvider);
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.tr('delete_subscription')),
        content: Text(l.trArgs('delete_confirm', [subscription.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l.tr('delete')),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          final repository = ref.read(subscriptionRepositoryProvider);
          await repository.delete(subscription.id);
          ref.invalidate(allSubscriptionsProvider);
          ref.invalidate(totalMonthlyCostProvider);
          ref.invalidate(dueSubscriptionsProvider(7));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.trArgs('deleted', [subscription.name]))),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.trArgs('error_deleting', ['$e']))),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final currencySymbol = sub.currency == 'TRY' ? '₺' : (sub.currency == 'USD' ? '\$' : sub.currency + ' ');
    
    final daysUntil = sub.nextBillingDate.difference(DateTime.now()).inDays;
    final trailingText = isUpcoming
        ? (daysUntil == 0 ? l.tr('today') : l.trArgs('in_days', [daysUntil.toString()]))
        : '$currencySymbol${sub.amount.toStringAsFixed(2)}';

    return SwipeableListItem(
      id: sub.id,
      onEdit: () {
        context.push('${AppRoutes.subscriptions}/edit/${sub.id}');
      },
      onDelete: () {
        _showDeleteConfirmation(context, ref, sub);
      },
      child: AppCard(
        onTap: onTap ?? () => context.push('${AppRoutes.subscriptions}/detail/${sub.id}'),
        padding: const EdgeInsets.all(12),
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(sub.iconUrl),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUpcoming 
                        ? '$currencySymbol${sub.amount.toStringAsFixed(2)}'
                        : l.tr(sub.billingCycle.name.toLowerCase()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  trailingText,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUpcoming 
                            ? Theme.of(context).colorScheme.error 
                            : Theme.of(context).colorScheme.primary,
                      ),
                ),
                if (!isUpcoming)
                  Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String? iconUrl) {
    if (iconUrl == null) return Icons.subscriptions;
    // Basic mapping
    return Icons.subscriptions;
  }
}

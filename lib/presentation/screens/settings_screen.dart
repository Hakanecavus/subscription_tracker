import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';
import 'package:subscription_tracker/presentation/providers/core_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final l = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tr('settings')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            _SectionHeader(title: l.tr('preferences')),
            _SettingsTile(
              title: l.tr('default_currency'),
              trailing: _getCurrencyLabel(ref),
              onTap: () => _showCurrencyPicker(context, ref, l),
            ),
            _SettingsTile(
              title: l.tr('theme'),
              trailing: _getThemeLabel(themeMode, l),
              onTap: () => _showThemePicker(context, ref, themeMode, l),
            ),
            _SettingsTile(
              title: l.tr('language'),
              trailing: _getLanguageLabel(ref),
              onTap: () => _showLanguagePicker(context, ref, l),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l.tr('notifications')),
            _buildNotificationSwitch(context, ref, l),
            _SettingsTile(
              title: l.tr('reminder_days'),
              trailing: _getReminderDaysLabel(ref, l),
              onTap: () => _showReminderDaysPicker(context, ref, l),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l.tr('security_data')),
            _buildBiometricSwitch(context, ref, l),
            _SettingsTile(
              title: l.tr('export_data'),
              onTap: () => _exportData(context, ref, l),
            ),
            _SettingsTile(
              title: l.tr('import_data'),
              onTap: () => _showImportDialog(context, ref, l),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l.tr('about')),
            ListTile(
              title: Text(l.tr('version')),
              trailing: const Text('1.0.0'),
            ),
            _SettingsTile(
              title: l.tr('rate_app'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.tr('thank_you'))),
                );
              },
            ),
            _SettingsTile(
              title: l.tr('privacy_policy'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.tr('privacy_browser'))),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============== THEME ==============
  String _getThemeLabel(ThemeModeState mode, AppLocalizations l) {
    switch (mode) {
      case ThemeModeState.light:
        return l.tr('light');
      case ThemeModeState.dark:
        return l.tr('dark');
      case ThemeModeState.system:
        return l.tr('system');
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeModeState currentMode, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l.tr('select_theme'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...ThemeModeState.values.map((mode) => RadioListTile<ThemeModeState>(
                    title: Text(_getThemeLabel(mode, l)),
                    value: mode,
                    groupValue: currentMode,
                    onChanged: (val) {
                      if (val != null) {
                        Future.microtask(() => ref.read(themeModeProvider.notifier).state = val);
                        Navigator.of(ctx).pop();
                      }
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ============== CURRENCY ==============
  String _getCurrencyLabel(WidgetRef ref) {
    return ref.watch(selectedCurrencyProvider);
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final currencies = ['USD \$', 'EUR €', 'GBP £', 'TRY ₺', 'JPY ¥', 'CAD \$', 'AUD \$'];
    final currentCurrency = ref.read(selectedCurrencyProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l.tr('select_currency'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: currencies.map((currency) => RadioListTile<String>(
                        title: Text(currency),
                        value: currency,
                        groupValue: currentCurrency,
                        onChanged: (val) {
                          if (val != null) {
                            Future.microtask(() => ref.read(selectedCurrencyProvider.notifier).state = val);
                            Navigator.of(ctx).pop();
                          }
                        },
                      )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============== LANGUAGE ==============
  String _getLanguageLabel(WidgetRef ref) {
    return ref.watch(selectedLanguageProvider);
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final languages = ['English', 'Türkçe', 'Español', 'Français', 'Deutsch'];
    final currentLang = ref.read(selectedLanguageProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (_, scrollController) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l.tr('select_language'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: languages.map((lang) => RadioListTile<String>(
                        title: Text(lang),
                        value: lang,
                        groupValue: currentLang,
                        onChanged: (val) {
                          if (val != null) {
                            Future.microtask(() => ref.read(selectedLanguageProvider.notifier).state = val);
                            Navigator.of(ctx).pop();
                          }
                        },
                      )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============== NOTIFICATIONS ==============
  Widget _buildNotificationSwitch(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final enabled = ref.watch(notificationsEnabledProvider);
    return SwitchListTile(
      title: Text(l.tr('notifications')),
      subtitle: Text(l.tr('notifications_subtitle')),
      value: enabled,
      onChanged: (value) {
        ref.read(notificationsEnabledProvider.notifier).state = value;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(value ? l.tr('notifications_enabled') : l.tr('notifications_disabled'))),
        );
      },
    );
  }

  String _getReminderDaysLabel(WidgetRef ref, AppLocalizations l) {
    final days = ref.watch(reminderDaysProvider);
    return '$days ${l.tr('days')}';
  }

  void _showReminderDaysPicker(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final dayOptions = [1, 2, 3, 5, 7, 14, 30];
    final currentDays = ref.read(reminderDaysProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l.tr('remind_me_before'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: dayOptions.map((d) => RadioListTile<int>(
                        title: Text(d == 1
                            ? l.trArgs('day_before', ['$d'])
                            : l.trArgs('days_before', ['$d'])),
                        value: d,
                        groupValue: currentDays,
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(reminderDaysProvider.notifier).state = val;
                            Navigator.of(ctx).pop();
                          }
                        },
                      )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============== BIOMETRIC ==============
  Widget _buildBiometricSwitch(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final enabled = ref.watch(biometricLockProvider);
    return SwitchListTile(
      title: Text(l.tr('biometric_lock')),
      subtitle: Text(l.tr('biometric_subtitle')),
      value: enabled,
      onChanged: (value) {
        ref.read(biometricLockProvider.notifier).state = value;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(value ? l.tr('biometric_enabled') : l.tr('biometric_disabled'))),
        );
      },
    );
  }

  // ============== EXPORT ==============
  Future<void> _exportData(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.exportAndShare();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.tr('export_failed')}: $e')),
        );
      }
    }
  }

  // ============== IMPORT ==============
  Future<void> _showImportDialog(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.tr('import_data')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.tr('paste_backup_data')),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l.tr('backup_json_hint'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              final jsonData = controller.text.trim();
              if (jsonData.isEmpty) return;

              Navigator.of(ctx).pop();

              try {
                final backupService = ref.read(backupServiceProvider);
                final success = await backupService.importFromJson(jsonData);

                if (success && context.mounted) {
                  // Refresh providers
                  ref.invalidate(allSubscriptionsProvider);
                  ref.invalidate(totalMonthlyCostProvider);
                  ref.invalidate(allCategoriesProvider);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.tr('import_success'))),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l.tr('import_failed')}: $e')),
                  );
                }
              }
            },
            child: Text(l.tr('import')),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) ...[
            Text(trailing!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            )),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

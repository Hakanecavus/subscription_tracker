import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/repositories/subscription_repository.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';
import 'package:subscription_tracker/presentation/providers/core_providers.dart';
import 'package:subscription_tracker/presentation/widgets/common_widgets.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final String? subscriptionId;

  const AddSubscriptionScreen({super.key, this.subscriptionId});

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.subscriptionId != null) {
      _tabController.index = 1; // Manual tab for editing
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final isEditing = widget.subscriptionId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subscription' : l.tr('add_subscription')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: isEditing ? null : TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l.tr('templates')),
            Tab(text: l.tr('manual')),
          ],
        ),
      ),
      body: SafeArea(
        child: isEditing 
          ? _ManualTab(subscriptionId: widget.subscriptionId)
          : TabBarView(
              controller: _tabController,
              children: [
                _TemplatesTab(onSelect: (data) {
                  ref.read(selectedTemplateProvider.notifier).state = data;
                  _tabController.animateTo(1);
                }),
                const _ManualTab(),
              ],
            ),
      ),
    );
  }
}

class _TemplatesTab extends ConsumerWidget {
  final Function(Map<String, dynamic>) onSelect;
  const _TemplatesTab({required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CustomTextField(
            labelText: l.tr('search_templates'),
            hintText: 'e.g. Netflix, Spotify',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _TemplateItem(
                  name: 'Netflix',
                  price: 15.99,
                  icon: Icons.movie,
                  color: Colors.red,
                  onSelect: onSelect,
                ),
                _TemplateItem(
                  name: 'Spotify',
                  price: 9.99,
                  icon: Icons.music_note,
                  color: Colors.green,
                  onSelect: onSelect,
                ),
                _TemplateItem(
                  name: 'Dropbox',
                  price: 9.99,
                  icon: Icons.cloud,
                  color: Colors.blue,
                  onSelect: onSelect,
                ),
                _TemplateItem(
                  name: 'YouTube Premium',
                  price: 13.99,
                  icon: Icons.play_circle,
                  color: Colors.redAccent,
                  onSelect: onSelect,
                ),
                _TemplateItem(
                  name: 'iCloud+',
                  price: 2.99,
                  icon: Icons.cloud_queue,
                  color: Colors.lightBlue,
                  onSelect: onSelect,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => onSelect({}),
                    child: Text(l.tr('cant_find')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateItem extends StatelessWidget {
  final String name;
  final double price;
  final IconData icon;
  final Color color;
  final Function(Map<String, dynamic>) onSelect;

  const _TemplateItem({
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        onTap: () => onSelect({
          'name': name,
          'amount': price,
          'icon': icon,
          'color': color,
        }),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('\$$price/mo', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualTab extends ConsumerStatefulWidget {
  final String? subscriptionId;
  const _ManualTab({this.subscriptionId});

  @override
  ConsumerState<_ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends ConsumerState<_ManualTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  late DateTime _startDate;
  String _billingCycle = 'Monthly';
  IconData _selectedIcon = Icons.subscriptions;
  Color _selectedColor = Colors.blue;
  String? _selectedCategoryId;
  bool _isSaving = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    
    // Listen to template selection (for Add mode)
    if (widget.subscriptionId == null) {
      Future.delayed(Duration.zero, () {
        final template = ref.read(selectedTemplateProvider);
        if (template != null) {
          _applyTemplate(template);
        }
      });
    }
  }

  void _applyTemplate(Map<String, dynamic> template) {
    if (template['name'] != null) _nameController.text = template['name'] as String;
    if (template['amount'] != null) _amountController.text = template['amount'].toString();
    if (template['icon'] != null) _selectedIcon = template['icon'] as IconData;
    if (template['color'] != null) _selectedColor = template['color'] as Color;
    if (template['categoryId'] != null) _selectedCategoryId = template['categoryId'] as String;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  BillingCycle _mapBillingCycle(String value) {
    switch (value) {
      case 'Weekly':
        return BillingCycle.weekly;
      case 'Monthly':
        return BillingCycle.monthly;
      case 'Yearly':
        return BillingCycle.yearly;
      default:
        return BillingCycle.monthly;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _showIconPicker() {
    final icons = [
      Icons.subscriptions, Icons.movie, Icons.music_note, Icons.cloud,
      Icons.play_circle, Icons.book, Icons.gamepad, Icons.fitness_center,
      Icons.shopping_cart, Icons.restaurant, Icons.home, Icons.commute,
    ];
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
          itemCount: icons.length,
          itemBuilder: (ctx, i) => IconButton(
            icon: Icon(icons[i], color: _selectedColor),
            onPressed: () {
              setState(() => _selectedIcon = icons[i]);
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.pink, Colors.amber, Colors.teal,
      Colors.indigo, Colors.brown, Colors.grey, Colors.cyan,
    ];
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
          itemCount: colors.length,
          itemBuilder: (ctx, i) => InkWell(
            onTap: () {
              setState(() => _selectedColor = colors[i]);
              Navigator.pop(ctx);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final amount = double.parse(_amountController.text.trim());
      final cycle = _mapBillingCycle(_billingCycle);
      final nextBilling = cycle.calculateNextBillingDate(_startDate);
      final currency = ref.read(selectedCurrencyProvider);
      final currencyCode = currency.split(' ').first;

      final repository = ref.read(subscriptionRepositoryProvider);
      
      if (widget.subscriptionId != null) {
        // Edit mode
        final params = UpdateSubscriptionParams(
          id: widget.subscriptionId!,
          name: name,
          amount: amount,
          currency: currencyCode,
          billingCycle: cycle,
          nextBillingDate: nextBilling,
          categoryId: _selectedCategoryId,
          paymentMethod: PaymentMethod.other,
        );
        final result = await repository.update(params);
        if (result.isSuccess) {
          _handleSuccess(name);
        } else {
          _handleError(result.failureOrNull);
        }
      } else {
        // Add mode
        final params = CreateSubscriptionParams(
          name: name,
          amount: amount,
          currency: currencyCode,
          billingCycle: cycle,
          startDate: _startDate,
          nextBillingDate: nextBilling,
          categoryId: _selectedCategoryId,
          paymentMethod: PaymentMethod.other,
        );
        final result = await repository.create(params);
        if (result.isSuccess) {
          _handleSuccess(name);
        } else {
          _handleError(result.failureOrNull);
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleSuccess(String name) {
    if (mounted) {
      setState(() => _isSaving = false);
      ref.invalidate(allSubscriptionsProvider);
      ref.invalidate(totalMonthlyCostProvider);
      ref.invalidate(dueSubscriptionsProvider(7));
      if (widget.subscriptionId != null) {
        ref.invalidate(subscriptionByIdProvider(widget.subscriptionId!));
      }
      ref.read(selectedTemplateProvider.notifier).state = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name saved successfully!')),
      );
      context.pop();
    }
  }

  void _handleError(dynamic error) {
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Load existing data if editing (Fixed logic using ref.watch + Future.microtask)
    if (widget.subscriptionId != null && !_isDataLoaded) {
      final subAsync = ref.watch(subscriptionByIdProvider(widget.subscriptionId!));
      subAsync.whenData((sub) {
        if (sub != null && !_isDataLoaded) {
          Future.microtask(() {
            if (mounted && !_isDataLoaded) {
              setState(() {
                _nameController.text = sub.name;
                _amountController.text = sub.amount.toString();
                _startDate = sub.startDate;
                _billingCycle = sub.billingCycle.name.substring(0, 1).toUpperCase() + sub.billingCycle.name.substring(1).toLowerCase();
                _selectedCategoryId = sub.categoryId;
                _isDataLoaded = true;
              });
            }
          });
        }
      });
    }

    // Check for template update (only in Add mode)
    if (widget.subscriptionId == null) {
      ref.listen(selectedTemplateProvider, (prev, next) {
        if (next != null) {
          _applyTemplate(next);
        }
      });
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Icon & Color Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _showColorPicker,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: _selectedColor.withOpacity(0.2),
                    child: IconButton(
                      icon: Icon(_selectedIcon, size: 30, color: _selectedColor),
                      onPressed: _showIconPicker,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameController,
              labelText: l.tr('name'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              labelText: l.tr('amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Required';
                if (double.tryParse(value.trim()) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l.tr('billing_cycle'),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _billingCycle,
              items: ['Weekly', 'Monthly', 'Yearly']
                  .map((e) => DropdownMenuItem(value: e, child: Text(l.tr(e.toLowerCase()))))
                  .toList(),
              onChanged: (v) => v != null ? setState(() => _billingCycle = v) : null,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(allCategoriesProvider);
                return categoriesAsync.when(
                  data: (categories) => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l.tr('category'),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    value: _selectedCategoryId,
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(l.tr('uncategorized')),
                      ),
                      ...categories.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: Color(c.colorValue), size: 12),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                );
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: l.tr('start_date'),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(text: dateFormat.format(_startDate)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: widget.subscriptionId != null ? 'Save Changes' : l.tr('save_subscription'),
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveSubscription,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

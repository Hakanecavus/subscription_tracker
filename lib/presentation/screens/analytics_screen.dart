import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/usecases/analysis_services.dart';
import 'package:collection/collection.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';
import 'package:subscription_tracker/presentation/widgets/common_widgets.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final totalSpentMap = ref.watch(totalSpendingProvider);
    final categoryAnalysisAsync = ref.watch(categoryAnalysisProvider);
    final selectedCurrency = ref.watch(selectedAnalyticsCurrencyProvider);
    final period = ref.watch(analyticsPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tr('analytics')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Currency Filter
                if (totalSpentMap.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCurrency ?? totalSpentMap.keys.first,
                      underline: const SizedBox(),
                      items: totalSpentMap.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => ref.read(selectedAnalyticsCurrencyProvider.notifier).state = v,
                    ),
                  ),
                // Period Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<AnalyticsPeriod>(
                    value: period,
                    underline: const SizedBox(),
                    items: AnalyticsPeriod.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(l.tr(e.name)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(analyticsPeriodProvider.notifier).state = v;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StatCard(
              title: l.tr('total_spent'),
              value: totalSpentMap.isEmpty 
                ? '0.00' 
                : '${(totalSpentMap[selectedCurrency ?? totalSpentMap.keys.first] ?? 0.0).toStringAsFixed(2)} ${selectedCurrency ?? totalSpentMap.keys.first}',
              iconOrTrend: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_neutral, color: Theme.of(context).colorScheme.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(l.tr(period.name), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(l.tr('spending_by_category'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            categoryAnalysisAsync.when(
              data: (analysis) {
                if (analysis.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Add subscriptions to see analysis'),
                  ));
                }
                
                final total = analysis.values.fold(0.0, (sum, a) => sum + a.totalSpend);

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Consumer(builder: (context, ref, _) {
                        final cats = ref.watch(allCategoriesProvider).value ?? [];
                        return _PieChartSection(analysis: analysis, total: total, categories: cats);
                      }),
                    ),
                    const SizedBox(height: 24),
                    Consumer(builder: (context, ref, _) {
                      final cats = ref.watch(allCategoriesProvider).value ?? [];
                      final l = ref.watch(appLocalizationsProvider);
                      return Column(
                        children: analysis.values.map((a) {
                          final subCurrency = a.subscriptions.firstOrNull?.currency ?? '';
                          return _CategoryRow(
                            name: _getCategoryName(a.categoryId, cats, l),
                            amount: '${a.totalSpend.toStringAsFixed(2)} $subCurrency',
                            percent: total > 0 ? (a.totalSpend / total * 100).toStringAsFixed(0) : '0',
                            icon: _getCategoryIcon(a.categoryId, cats),
                            color: _getCategoryColor(a.categoryId, cats),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                );
              },
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 32),
            Text(l.tr('monthly_trend'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const SizedBox(
              height: 200,
              child: _BarChartSection(), // Still mock trend, needs historical data
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String id, List<Category> categories) {
    try {
      final category = categories.firstWhereOrNull((c) => c.id == id);
      if (category != null) return Color(category.colorValue);
      
      if (id == 'uncategorized') return Colors.grey;
      final colors = [Colors.blue, Colors.purple, Colors.cyan, Colors.orange, Colors.green, Colors.red];
      return colors[id.hashCode % colors.length];
    } catch (_) {
      return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String id, List<Category> categories) {
    try {
      final category = categories.firstWhereOrNull((c) => c.id == id);
      if (category?.iconName == 'movie') return Icons.movie_outlined;
      if (category?.iconName == 'work') return Icons.work_outline;
      if (category?.iconName == 'bolt') return Icons.bolt;
      if (category?.iconName == 'favorite') return Icons.favorite_border;
      if (category?.iconName == 'account_balance') return Icons.account_balance;
      if (category?.iconName == 'shopping_cart') return Icons.shopping_cart_outlined;
      if (category?.iconName == 'school') return Icons.school_outlined;
      
      return Icons.category_outlined;
    } catch (_) {
      return Icons.category_outlined;
    }
  }

  String _getCategoryName(String id, List<Category> categories, AppLocalizations l) {
    try {
      final category = categories.firstWhereOrNull((c) => c.id == id);
      if (category != null) {
        final translationKey = category.name.toLowerCase().replaceAll(' ', '_').replaceAll('&', '');
        return l.tr(translationKey);
      }
      
      return id == 'uncategorized' ? l.tr('uncategorized') : id;
    } catch (_) {
      return l.tr('uncategorized');
    }
  }
}

class _PieChartSection extends StatelessWidget {
  final Map<String, CategoryAnalysis> analysis;
  final double total;
  final List<Category> categories;

  const _PieChartSection({
    required this.analysis,
    required this.total,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [];
    int i = 0;

    analysis.forEach((key, value) {
      final percent = total > 0 ? (value.totalSpend / total * 100) : 0.0;
      
      // Get color from categories if possible
      Color sectionColor;
      try {
        final cat = categories.firstWhereOrNull((c) => c.id == key);
        if (cat != null) {
          sectionColor = Color(cat.colorValue);
        } else {
          final colors = [Colors.blue, Colors.purple, Colors.cyan, Colors.orange, Colors.green, Colors.red];
          sectionColor = key == 'uncategorized' ? Colors.grey : colors[i % colors.length];
        }
      } catch (_) {
        sectionColor = Colors.grey;
      }

      sections.add(PieChartSectionData(
        value: value.totalSpend,
        title: '${percent.toStringAsFixed(0)}%',
        color: sectionColor,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      i++;
    });

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final String amount;
  final String percent;
  final IconData icon;
  final Color color;

  const _CategoryRow({
    required this.name,
    required this.amount,
    required this.percent,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('$percent%', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChartSection extends ConsumerWidget {
  const _BarChartSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current trend is still mock since historical payments aren't fully implemented in DB yet
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 300,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final l = ref.watch(appLocalizationsProvider);
                final months = l.localeCode == 'tr' 
                    ? ['Ağu', 'Eyl', 'Eki', 'Kas', 'Ara', 'Oca']
                    : ['Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];
                if (val.toInt() >= months.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(months[val.toInt()], style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarGroup(0, 150, Theme.of(context).colorScheme.primaryContainer),
          _buildBarGroup(1, 180, Theme.of(context).colorScheme.primaryContainer),
          _buildBarGroup(2, 210, Theme.of(context).colorScheme.primaryContainer),
          _buildBarGroup(3, 215, Theme.of(context).colorScheme.primaryContainer),
          _buildBarGroup(4, 230, Theme.of(context).colorScheme.primaryContainer),
          _buildBarGroup(5, 247.5, Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

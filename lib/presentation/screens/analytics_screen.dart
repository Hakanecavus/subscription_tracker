import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/localization/app_localizations.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/domain/usecases/analysis_services.dart';
import 'package:collection/collection.dart';
import 'package:subscription_tracker/presentation/providers/app_providers.dart';
import 'package:intl/intl.dart';
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
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(l.tr('add_subscriptions_to_see_analysis')),
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
        final translationKey = category.name.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+$'), '');
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
    final subscriptionsAsync = ref.watch(allSubscriptionsProvider);
    final selectedCurrency = ref.watch(selectedAnalyticsCurrencyProvider);

    return subscriptionsAsync.when(
      data: (subs) {
        if (subs.isEmpty) {
          final l = ref.watch(appLocalizationsProvider);
          return EmptyStateWidget(
            message: l.tr('no_subscriptions'),
            icon: Icons.subscriptions_outlined,
          );
        }

        // Determine currency to analyze
        final currencyToShow = selectedCurrency ?? (subs.isNotEmpty ? subs.first.currency : null);
        if (currencyToShow == null) return const SizedBox();

        final filteredSubs = subs.where((s) => s.currency == currencyToShow).toList();
        
        // Calculate last 6 months
        final now = DateTime.now();
        final last6MonthsList = List.generate(6, (i) {
          final date = DateTime(now.year, now.month - (5 - i), 1);
          return date;
        });

        final monthlyTotals = last6MonthsList.map((monthDate) {
          double total = 0;
          for (final sub in filteredSubs) {
            // Check if subscription was active in this month
            // A simple logic: if month >= startDate month/year
            final subStart = DateTime(sub.startDate.year, sub.startDate.month, 1);
            if (!monthDate.isBefore(subStart)) {
              total += sub.monthlyCost;
            }
          }
          return total;
        }).toList();

        final maxTotal = monthlyTotals.fold(0.0, (m, v) => v > m ? v : m);
        final maxY = (maxTotal == 0) ? 100.0 : maxTotal * 1.2;

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Theme.of(context).colorScheme.primaryContainer,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    rod.toY.toStringAsFixed(2),
                    TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, meta) {
                    final l = ref.watch(appLocalizationsProvider);
                    if (val.toInt() < 0 || val.toInt() >= last6MonthsList.length) return const SizedBox();
                    
                    final date = last6MonthsList[val.toInt()];
                    final monthFormat = DateFormat.MMM(l.localeCode);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(monthFormat.format(date), style: const TextStyle(fontSize: 10)),
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
            barGroups: List.generate(monthlyTotals.length, (i) {
              final isLast = i == monthlyTotals.length - 1;
              return _buildBarGroup(
                i, 
                monthlyTotals[i], 
                isLast ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer
              );
            }),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
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

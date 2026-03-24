import 'package:subscription_tracker/domain/entities/subscription.dart';

class UpcomingPaymentsService {
  List<Subscription> getUpcomingPayments({
    required List<Subscription> subscriptions,
    required int days,
  }) {
    final threshold = DateTime.now().add(Duration(days: days));

    return subscriptions
        .where((sub) => sub.nextBillingDate.isBefore(threshold) && sub.isActive)
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  }
}

class DuplicateDetector {
  static bool isLikelyDuplicate({
    required String name,
    required String? categoryId,
    required List<Subscription> existing,
    double threshold = 0.8,
  }) {
    final normalizedName = _normalize(name);

    return existing.any((sub) {
      if (!sub.isActive) return false;
      final similarity = _calculateSimilarity(normalizedName, _normalize(sub.name));
      return similarity >= threshold && sub.categoryId == categoryId;
    });
  }

  static String _normalize(String input) {
    return input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static double _calculateSimilarity(String a, String b) {
    final wordsA = a.split(' ').toSet();
    final wordsB = b.split(' ').toSet();
    if (wordsA.isEmpty || wordsB.isEmpty) return 0.0;

    final intersection = wordsA.intersection(wordsB);
    final union = wordsA.union(wordsB);
    return intersection.length / union.length;
  }
}

class CategoryAnalysisService {
  Map<String, CategoryAnalysis> analyzeByCategory(List<Subscription> subscriptions) {
    final analysis = <String, List<Subscription>>{};

    for (final sub in subscriptions) {
      if (!sub.isActive) continue;
      final catId = sub.categoryId ?? 'uncategorized';
      analysis.putIfAbsent(catId, () => []).add(sub);
    }

    return analysis.map((categoryId, subs) {
      final total = subs.fold(0.0, (sum, s) => sum + s.monthlyCost);
      return MapEntry(
        categoryId,
        CategoryAnalysis(
          categoryId: categoryId,
          count: subs.length,
          totalSpend: total,
          averageSpend: total / subs.length,
          subscriptions: subs,
        ),
      );
    });
  }
}

class CategoryAnalysis {
  final String categoryId;
  final int count;
  final double totalSpend;
  final double averageSpend;
  final List<Subscription> subscriptions;

  CategoryAnalysis({
    required this.categoryId,
    required this.count,
    required this.totalSpend,
    required this.averageSpend,
    required this.subscriptions,
  });
}

import 'package:flutter/material.dart';
import 'package:subscription_tracker/presentation/widgets/common_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    // Navigate to dashboard
    // context.go('/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _WelcomeStep(onNext: _nextPage),
                  _NotificationsStep(onNext: _nextPage),
                  _FirstSubscriptionStep(onNext: _nextPage),
                  _PremiumPreviewStep(onNext: _finishOnboarding),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subscriptions_outlined, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 48),
          Text('Track Your Subs', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'Manage all subscriptions in one place. Never miss a payment.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(text: 'Get Started', onPressed: onNext),
          ),
        ],
      ),
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  final VoidCallback onNext;

  const _NotificationsStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active_outlined, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 48),
          Text('Stay in the Loop', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'Get notified before payments are due.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(text: 'Allow Notifications', onPressed: onNext),
          ),
          const SizedBox(height: 16),
          AppButton(text: 'Skip for now', isGhost: true, onPressed: onNext),
        ],
      ),
    );
  }
}

class _FirstSubscriptionStep extends StatelessWidget {
  final VoidCallback onNext;

  const _FirstSubscriptionStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppCard(
            onTap: onNext,
            child: const Row(
              children: [
                Icon(Icons.mobile_friendly, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add from Template', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Quick setup'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Text('─── OR ───', style: TextStyle(color: Colors.grey)),
          ),
          AppCard(
            onTap: onNext,
            child: const Row(
              children: [
                Icon(Icons.edit_note, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Manually', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Full control'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onNext, child: const Text('Skip for now →')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumPreviewStep extends StatelessWidget {
  final VoidCallback onNext;

  const _PremiumPreviewStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, size: 80, color: Colors.amber),
          const SizedBox(height: 24),
          Text('Premium', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const _FeatureRow(text: 'Unlimited subscriptions'),
          const _FeatureRow(text: 'Advanced analytics'),
          const _FeatureRow(text: 'Cloud backup'),
          const _FeatureRow(text: 'Custom categories'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Start Free Trial',
              onPressed: onNext,
            ),
          ),
          const SizedBox(height: 8),
          const Text('7 days free, then \$4.99/mo', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          AppButton(text: 'Continue with Free', isGhost: true, onPressed: onNext),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/core/utils/toast_helper.dart';
import 'package:aspire/services/revenue_cat_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _termsUrl = 'https://aspire.sixtusagbo.dev/terms';
const _privacyUrl = 'https://aspire.sixtusagbo.dev/privacy';

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ToastHelper.showError('Could not open link');
  }
}

class PaywallScreen extends HookConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueCatService = ref.read(revenueCatServiceProvider);
    final isLoading = useState(true);
    final isPurchasing = useState(false);
    final isPremium = useState(false);
    final offerings = useState<Offerings?>(null);

    useEffect(() {
      _loadData(revenueCatService, offerings, isPremium, isLoading);
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : isPremium.value
            ? const _PremiumActiveContent()
            : _PaywallContent(
                offerings: offerings.value,
                isPurchasing: isPurchasing,
                onPurchase: (package) => _purchase(
                  context,
                  revenueCatService,
                  package,
                  isPurchasing,
                ),
                onRestore: () =>
                    _restore(context, revenueCatService, isPurchasing),
              ),
      ),
    );
  }

  Future<void> _loadData(
    RevenueCatService service,
    ValueNotifier<Offerings?> offerings,
    ValueNotifier<bool> isPremium,
    ValueNotifier<bool> isLoading,
  ) async {
    final results = await Future.wait([
      service.isPremium(),
      service.getOfferings(),
    ]);
    isPremium.value = results[0] as bool;
    offerings.value = results[1] as Offerings?;
    isLoading.value = false;
  }

  Future<void> _purchase(
    BuildContext context,
    RevenueCatService service,
    Package package,
    ValueNotifier<bool> isPurchasing,
  ) async {
    isPurchasing.value = true;
    final success = await service.purchasePackage(package);
    isPurchasing.value = false;

    if (success && context.mounted) {
      ToastHelper.showSuccess('Welcome to Premium!');
      Navigator.pop(context, true);
    }
  }

  Future<void> _restore(
    BuildContext context,
    RevenueCatService service,
    ValueNotifier<bool> isPurchasing,
  ) async {
    isPurchasing.value = true;
    final success = await service.restorePurchases();
    isPurchasing.value = false;

    if (context.mounted) {
      if (success) {
        ToastHelper.showSuccess('Purchases restored!');
        Navigator.pop(context, true);
      } else {
        ToastHelper.showInfo('No purchases to restore');
      }
    }
  }
}

class _PremiumActiveContent extends StatelessWidget {
  const _PremiumActiveContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),

          const Spacer(),

          // Premium badge
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: AppTheme.primaryPink,
              size: 56,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "You're Premium!",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Text(
            'You have access to all premium features.\n'
            'Thank you for your support!',
            style: TextStyle(color: context.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Features reminder
          _FeatureItem(
            icon: Icons.check_circle,
            title: 'Unlimited Goals',
            description: 'Create as many dreams as you have',
          ),
          _FeatureItem(
            icon: Icons.check_circle,
            title: 'More AI Suggestions',
            description: 'Get 10 micro-actions per goal',
          ),
          _FeatureItem(
            icon: Icons.check_circle,
            title: 'Custom Reminders',
            description: 'Set different reminder times per goal',
          ),
          _FeatureItem(
            icon: Icons.check_circle,
            title: 'Custom Categories',
            description: 'Create your own goal categories',
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _PaywallContent extends StatelessWidget {
  final Offerings? offerings;
  final ValueNotifier<bool> isPurchasing;
  final Function(Package) onPurchase;
  final VoidCallback onRestore;

  const _PaywallContent({
    required this.offerings,
    required this.isPurchasing,
    required this.onPurchase,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final currentOffering = offerings?.current;
    final monthly = currentOffering?.monthly;
    final annual = currentOffering?.annual;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),

              const SizedBox(height: 16),

              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Unlock Your Full Potential',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Go premium to crush all your goals',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Comparison table
              const _ComparisonTable(),

              const SizedBox(height: 32),

              // Pricing options
              if (currentOffering == null)
                Center(
                  child: Text(
                    'Unable to load pricing. Please try again.',
                    style: TextStyle(color: context.textSecondary),
                  ),
                )
              else ...[
                // Annual (best value)
                if (annual != null)
                  _PricingCard(
                    package: annual,
                    isRecommended: true,
                    onTap: () => onPurchase(annual),
                  ),

                const SizedBox(height: 12),

                // Monthly
                if (monthly != null)
                  _PricingCard(
                    package: monthly,
                    isRecommended: false,
                    onTap: () => onPurchase(monthly),
                  ),
              ],

              const SizedBox(height: 24),

              // Restore purchases
              Center(
                child: TextButton(
                  onPressed: onRestore,
                  child: const Text('Restore Purchases'),
                ),
              ),

              const SizedBox(height: 16),

              // Terms
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                    children: [
                      const TextSpan(text: 'Cancel anytime. '),
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          color: AppTheme.primaryPink,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl(_termsUrl),
                      ),
                      const TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Privacy',
                        style: TextStyle(
                          color: AppTheme.primaryPink,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl(_privacyUrl),
                      ),
                      const TextSpan(text: ' apply.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40), // Space for loading overlay
            ],
          ),
        ),

        // Loading overlay
        if (isPurchasing.value)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryPink, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Feature',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Premium',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          _ComparisonRow(feature: 'Active Goals', free: '3', premium: 'Unlimited'),
          _ComparisonRow(feature: 'AI Suggestions', free: '5', premium: '10'),
          _ComparisonRow(
            feature: 'Goal Reminders',
            free: null,
            premium: 'check',
          ),
          _ComparisonRow(
            feature: 'Custom Categories',
            free: null,
            premium: 'check',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String? free;
  final String? premium;
  final bool isLast;

  const _ComparisonRow({
    required this.feature,
    required this.free,
    required this.premium,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(feature, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(child: _buildValue(free, false)),
          Expanded(child: _buildValue(premium, true)),
        ],
      ),
    );
  }

  Widget _buildValue(String? value, bool isPremium) {
    if (value == null) {
      return const Icon(Icons.close, color: Colors.grey, size: 20);
    }
    if (value == 'check') {
      return Icon(
        Icons.check_circle,
        color: isPremium ? AppTheme.primaryPink : Colors.green,
        size: 20,
      );
    }
    return Text(
      value,
      style: TextStyle(
        fontSize: 14,
        fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
        color: isPremium ? AppTheme.primaryPink : null,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PricingCard extends StatelessWidget {
  final Package package;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PricingCard({
    required this.package,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final isAnnual = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRecommended
              ? AppTheme.primaryPink.withValues(alpha: 0.05)
              : null,
          border: Border.all(
            color: isRecommended ? AppTheme.primaryPink : context.borderColor,
            width: isRecommended ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isAnnual ? 'Annual' : 'Monthly',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAchievement,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAnnual ? 'Save 50% vs monthly' : 'Billed monthly',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceString,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isRecommended ? AppTheme.primaryPink : null,
                  ),
                ),
                Text(
                  isAnnual ? '/year' : '/month',
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

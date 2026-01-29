import 'package:aspire/core/theme/app_theme.dart';
import 'package:aspire/models/tip.dart';
import 'package:aspire/services/tip_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TipCard extends ConsumerWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipAsync = ref.watch(tipOfTheDayProvider);

    return tipAsync.when(
      data: (tip) => tip != null
          ? _TipContent(tip: tip)
          : const _EmptyTipCard(),
      loading: () => const _LoadingTipCard(),
      error: (_, __) => const _EmptyTipCard(),
    );
  }
}

class _TipContent extends StatelessWidget {
  final Tip tip;

  const _TipContent({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryPinkDeep.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: AppTheme.primaryPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tip of the Day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPink,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tip.text,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: context.isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (tip.author != null) ...[
            const SizedBox(height: 12),
            Text(
              '— ${tip.author}',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: context.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingTipCard extends StatelessWidget {
  const _LoadingTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: context.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _EmptyTipCard extends StatelessWidget {
  const _EmptyTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: AppTheme.primaryPink,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your daily tip is on its way!',
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

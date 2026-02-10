import 'package:share_plus/share_plus.dart';

/// Service for sharing achievements to social media
class ShareService {
  // TODO: Replace with Play Store link once app is published.
  static const _shareFooter =
      '\n\nDownload Aspire on Google Play today!'
      '\n#Aspire #PacksLight';

  /// Share a streak milestone achievement
  static Future<void> shareStreak(int streak) async {
    final message = _getStreakMessage(streak);
    await SharePlus.instance.share(
      ShareParams(
        text: '$message$_shareFooter',
        subject: 'My Aspire Streak',
      ),
    );
  }

  /// Share a completed goal
  static Future<void> shareGoalCompletion(String goalTitle) async {
    // Add exclamation only if title doesn't already end with one
    final title = goalTitle.endsWith('!') ? goalTitle : '$goalTitle!';
    await SharePlus.instance.share(
      ShareParams(
        text: "I just completed my goal: $title "
            "From dreaming to doing, one step at a time."
            "$_shareFooter",
        subject: 'Goal Completed!',
      ),
    );
  }

  static String _getStreakMessage(int streak) {
    if (streak >= 365) {
      return "A FULL YEAR of consistency! I just hit a $streak day streak on Aspire. "
          "Dreams don't work unless you do.";
    } else if (streak >= 100) {
      return "TRIPLE DIGITS! I just hit a $streak day streak on Aspire. "
          "100+ days of turning dreams into action.";
    } else if (streak >= 60) {
      return "Two months strong! I just hit a $streak day streak on Aspire. "
          "Consistency is my superpower.";
    } else if (streak >= 30) {
      return "A WHOLE MONTH! I just hit a $streak day streak on Aspire. "
          "30 days of showing up for my goals.";
    } else if (streak >= 14) {
      return "Two weeks of consistency! I just hit a $streak day streak on Aspire. "
          "Small actions, big dreams.";
    } else if (streak >= 7) {
      return "One week strong! I just hit a $streak day streak on Aspire. "
          "Building my dream life one day at a time.";
    } else {
      return "I'm on a $streak day streak on Aspire! "
          "Taking action on my goals every single day.";
    }
  }
}

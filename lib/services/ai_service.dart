import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'log_service.dart';

part 'ai_service.g.dart';

/// Generated micro-action from AI
class GeneratedAction {
  final String title;
  final int sortOrder;

  GeneratedAction({required this.title, required this.sortOrder});

  factory GeneratedAction.fromJson(Map<String, dynamic> json) {
    return GeneratedAction(
      title: json['title'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

/// Service for AI-powered features
class AIService {
  final _functions = FirebaseFunctions.instance;

  /// Generate micro-actions for a goal using AI
  Future<List<GeneratedAction>> generateMicroActions({
    required String goalTitle,
    String? goalDescription,
    String? category,
    DateTime? targetDate,
  }) async {
    Log.i('Generating micro-actions for: $goalTitle');

    try {
      final callable = _functions.httpsCallable('generateMicroActions');

      final result = await callable.call<Map<String, dynamic>>({
        'goalTitle': goalTitle,
        if (goalDescription != null) 'goalDescription': goalDescription,
        if (category != null) 'category': category,
        if (targetDate != null) 'targetDate': targetDate.toIso8601String(),
      });

      final data = result.data;
      final actions = (data['actions'] as List<dynamic>)
          .map((a) => GeneratedAction.fromJson(a as Map<String, dynamic>))
          .toList();

      Log.i('Generated ${actions.length} micro-actions');
      return actions;
    } on FirebaseFunctionsException catch (e) {
      Log.e('Firebase Functions error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, stack) {
      Log.e('Failed to generate micro-actions', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

@riverpod
AIService aiService(Ref ref) {
  return AIService();
}

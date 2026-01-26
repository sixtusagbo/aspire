import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/goal.dart';
import '../models/micro_action.dart';
import '../models/daily_log.dart';

part 'goal_service.g.dart';

/// Result of completing a micro-action
class ActionCompletionResult {
  final int xpEarned;
  final int newStreak;
  final int previousStreak;

  ActionCompletionResult({
    required this.xpEarned,
    required this.newStreak,
    required this.previousStreak,
  });

  /// Check if a streak milestone was just reached
  bool get isStreakMilestone {
    const milestones = [7, 14, 30, 60, 100, 365];
    return milestones.contains(newStreak) && newStreak > previousStreak;
  }
}

class GoalService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _goalsRef =>
      _firestore.collection('goals');

  CollectionReference<Map<String, dynamic>> get _actionsRef =>
      _firestore.collection('micro_actions');

  CollectionReference<Map<String, dynamic>> get _logsRef =>
      _firestore.collection('daily_logs');

  // ============ Goals ============

  /// Stream of all goals for a user
  Stream<List<Goal>> watchUserGoals(String userId) {
    return _goalsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GoalMapper.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  /// Stream of active (not completed) goals for a user
  Stream<List<Goal>> watchActiveGoals(String userId) {
    return _goalsRef
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GoalMapper.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  /// Get a single goal by ID
  Future<Goal?> getGoal(String goalId) async {
    final doc = await _goalsRef.doc(goalId).get();
    if (!doc.exists) return null;
    return GoalMapper.fromMap({...doc.data()!, 'id': doc.id});
  }

  /// Create a new goal
  Future<Goal> createGoal({
    required String userId,
    required String title,
    String? description,
    DateTime? targetDate,
    GoalCategory category = GoalCategory.personal,
  }) async {
    final docRef = _goalsRef.doc();
    final goal = Goal(
      id: docRef.id,
      userId: userId,
      title: title,
      description: description,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      category: category,
    );

    await docRef.set(goal.toMap()..remove('id'));
    return goal;
  }

  /// Update a goal
  Future<void> updateGoal(Goal goal) async {
    await _goalsRef.doc(goal.id).update(goal.toMap()..remove('id'));
  }

  /// Mark a goal as completed
  Future<void> completeGoal(String goalId) async {
    await _goalsRef.doc(goalId).update({
      'isCompleted': true,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a goal and all its micro-actions
  Future<void> deleteGoal(String goalId, String userId) async {
    final batch = _firestore.batch();

    // Delete all micro-actions for this goal (must include userId for security rules)
    final actions = await _actionsRef
        .where('goalId', isEqualTo: goalId)
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in actions.docs) {
      batch.delete(doc.reference);
    }

    // Delete the goal
    batch.delete(_goalsRef.doc(goalId));

    await batch.commit();
  }

  // ============ Micro Actions ============

  /// Stream of micro-actions for a goal
  Stream<List<MicroAction>> watchGoalActions(String goalId, String userId) {
    return _actionsRef
        .where('goalId', isEqualTo: goalId)
        .where('userId', isEqualTo: userId)
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    MicroActionMapper.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// Stream of today's micro-actions for a user
  Stream<List<MicroAction>> watchTodayActions(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _actionsRef
        .where('userId', isEqualTo: userId)
        .where('scheduledFor', isGreaterThanOrEqualTo: startOfDay)
        .where('scheduledFor', isLessThan: endOfDay)
        .orderBy('scheduledFor')
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    MicroActionMapper.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// Create a micro-action
  Future<MicroAction> createMicroAction({
    required String goalId,
    required String userId,
    required String title,
    DateTime? scheduledFor,
    int sortOrder = 0,
  }) async {
    final docRef = _actionsRef.doc();
    final action = MicroAction(
      id: docRef.id,
      goalId: goalId,
      userId: userId,
      title: title,
      scheduledFor: scheduledFor,
      sortOrder: sortOrder,
    );

    await docRef.set(action.toMap()..remove('id'));

    // Update goal's total actions count
    await _goalsRef.doc(goalId).update({
      'totalActionsCount': FieldValue.increment(1),
    });

    return action;
  }

  /// Update a micro-action
  Future<void> updateMicroAction(MicroAction action) async {
    await _actionsRef.doc(action.id).update(action.toMap()..remove('id'));
  }

  /// Complete a micro-action and award XP
  Future<ActionCompletionResult> completeMicroAction({
    required String actionId,
    required String goalId,
    required String userId,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const xpReward = 10;

    final batch = _firestore.batch();

    // Mark action as completed
    batch.update(_actionsRef.doc(actionId), {
      'isCompleted': true,
      'completedAt': Timestamp.fromDate(now),
    });

    // Update goal's completed actions count
    batch.update(_goalsRef.doc(goalId), {
      'completedActionsCount': FieldValue.increment(1),
    });

    // Update or create daily log using set with merge to avoid permission issues
    final logId = DailyLog.generateId(now, userId);
    final logRef = _logsRef.doc(logId);
    batch.set(logRef, {
      'userId': userId,
      'date': Timestamp.fromDate(today),
      'actionsCompleted': FieldValue.increment(1),
      'xpEarned': FieldValue.increment(xpReward),
      'completedActionIds': FieldValue.arrayUnion([actionId]),
    }, SetOptions(merge: true));

    // Update user XP and streak
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();

    int previousStreak = 0;
    int newStreak = 1;

    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final lastActivity = userData['lastActivityDate'] as Timestamp?;
      final currentStreak = userData['currentStreak'] as int? ?? 0;
      final longestStreak = userData['longestStreak'] as int? ?? 0;

      previousStreak = currentStreak;
      newStreak = currentStreak;

      if (lastActivity != null) {
        final lastDate = lastActivity.toDate();
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final yesterday = today.subtract(const Duration(days: 1));

        if (lastDay.isBefore(yesterday)) {
          // Streak broken - reset to 1
          newStreak = 1;
        } else if (lastDay == yesterday) {
          // Consecutive day - increment streak
          newStreak = currentStreak + 1;
        }
        // If lastDay == today, streak stays the same (already counted today)
      } else {
        // First activity ever
        newStreak = 1;
      }

      final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

      batch.update(userRef, {
        'xp': FieldValue.increment(xpReward),
        'lastActivityDate': Timestamp.fromDate(today),
        'currentStreak': newStreak,
        'longestStreak': newLongest,
      });
    }

    await batch.commit();

    return ActionCompletionResult(
      xpEarned: xpReward,
      newStreak: newStreak,
      previousStreak: previousStreak,
    );
  }

  /// Delete a micro-action
  Future<void> deleteMicroAction(String actionId, String goalId) async {
    final batch = _firestore.batch();

    // Check if it was completed
    final doc = await _actionsRef.doc(actionId).get();
    final wasCompleted = doc.data()?['isCompleted'] ?? false;

    batch.delete(_actionsRef.doc(actionId));

    // Update goal's action counts
    batch.update(_goalsRef.doc(goalId), {
      'totalActionsCount': FieldValue.increment(-1),
      if (wasCompleted) 'completedActionsCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Reorder micro-actions
  Future<void> reorderActions(List<MicroAction> actions) async {
    final batch = _firestore.batch();

    for (var i = 0; i < actions.length; i++) {
      batch.update(_actionsRef.doc(actions[i].id), {'sortOrder': i});
    }

    await batch.commit();
  }

  // ============ Daily Logs ============

  /// Get today's log for a user
  Future<DailyLog?> getTodayLog(String userId) async {
    final today = DateTime.now();
    final logId = DailyLog.generateId(today, userId);
    final doc = await _logsRef.doc(logId).get();

    if (!doc.exists) return null;
    return DailyLogMapper.fromMap({...doc.data()!, 'id': doc.id});
  }

  /// Stream of daily logs for a user (last 30 days)
  Stream<List<DailyLog>> watchRecentLogs(String userId) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return _logsRef
        .where('userId', isEqualTo: userId)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo),
        )
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => DailyLogMapper.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  /// Count goals for a user (for free tier limit check)
  Future<int> countActiveGoals(String userId) async {
    final snapshot = await _goalsRef
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}

@riverpod
GoalService goalService(Ref ref) {
  return GoalService();
}

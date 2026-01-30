import 'package:aspire/data/sample_goal_templates.dart';
import 'package:aspire/models/goal_template.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_template_service.g.dart';

@riverpod
GoalTemplateService goalTemplateService(ref) => GoalTemplateService();

@riverpod
Future<List<GoalTemplate>> goalTemplates(ref) {
  final service = ref.watch(goalTemplateServiceProvider);
  return service.getTemplates();
}

class GoalTemplateService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('goal_templates');

  /// Watch all active templates
  Stream<List<GoalTemplate>> watchTemplates() {
    return _collection
        .where('isActive', isEqualTo: true)
        .orderBy('category')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GoalTemplateMapper.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// Get all active templates
  Future<List<GoalTemplate>> getTemplates() async {
    final snapshot =
        await _collection.where('isActive', isEqualTo: true).get();
    return snapshot.docs
        .map((doc) => GoalTemplateMapper.fromMap({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  /// Seed templates from sample data (only if collection is empty)
  Future<void> seedTemplatesIfNeeded() async {
    final snapshot = await _collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    await reseedTemplates();
  }

  /// Reseed all templates (clears existing and adds fresh)
  Future<void> reseedTemplates() async {
    // Delete existing templates
    final existing = await _collection.get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }

    // Add new templates
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (final template in sampleGoalTemplates) {
      final docRef = _collection.doc();
      batch.set(docRef, {
        ...template,
        'createdAt': Timestamp.fromDate(now),
        'isActive': true,
      });
    }

    await batch.commit();
  }
}

import 'dart:math';

import 'package:aspire/data/sample_tips.dart';
import 'package:aspire/models/tip.dart';
import 'package:aspire/services/log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tip_service.g.dart';

class TipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _random = Random();

  CollectionReference<Map<String, dynamic>> get _tipsCollection =>
      _firestore.collection('tips');

  /// Seed tips if collection is empty (call once on first launch)
  Future<void> seedTipsIfEmpty() async {
    try {
      final snapshot = await _tipsCollection.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        Log.d('Tips collection already has data, skipping seed');
        return;
      }

      Log.i('Seeding tips collection with ${sampleTips.length} tips...');
      final batch = _firestore.batch();
      for (final tip in sampleTips) {
        final docRef = _tipsCollection.doc();
        batch.set(docRef, tip);
      }
      await batch.commit();
      Log.i('Tips seeded successfully');
    } catch (e) {
      Log.e('Failed to seed tips: $e');
    }
  }

  /// Get a random tip for today (deterministic based on date)
  Future<Tip?> getTipOfTheDay() async {
    try {
      final snapshot =
          await _tipsCollection.where('isActive', isEqualTo: true).get();

      if (snapshot.docs.isEmpty) return null;

      // Use date as seed for consistent daily tip
      final today = DateTime.now();
      final seed = today.year * 10000 + today.month * 100 + today.day;
      final random = Random(seed);
      final index = random.nextInt(snapshot.docs.length);

      final doc = snapshot.docs[index];
      return TipMapper.fromMap({'id': doc.id, ...doc.data()});
    } catch (e) {
      return null;
    }
  }

  /// Get a random tip (not deterministic)
  Future<Tip?> getRandomTip() async {
    try {
      final snapshot =
          await _tipsCollection.where('isActive', isEqualTo: true).get();

      if (snapshot.docs.isEmpty) return null;

      final index = _random.nextInt(snapshot.docs.length);
      final doc = snapshot.docs[index];
      return TipMapper.fromMap({'id': doc.id, ...doc.data()});
    } catch (e) {
      return null;
    }
  }

  /// Get all active tips
  Future<List<Tip>> getAllTips() async {
    try {
      final snapshot =
          await _tipsCollection.where('isActive', isEqualTo: true).get();

      return snapshot.docs
          .map((doc) => TipMapper.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

@Riverpod(keepAlive: true)
TipService tipService(Ref ref) {
  return TipService();
}

@riverpod
Future<Tip?> tipOfTheDay(Ref ref) {
  final service = ref.watch(tipServiceProvider);
  return service.getTipOfTheDay();
}

import 'package:aspire/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_service.g.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user profile from Firestore
  Future<AppUser?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    // Inject the document ID since Firestore stores it separately
    final data = {'id': doc.id, ...doc.data()!};
    return AppUserMapper.fromMap(data);
  }

  /// Save user profile to Firestore
  Future<void> saveUser(AppUser profile) async {
    await _firestore.collection('users').doc(profile.id).set(profile.toMap());
  }

  /// Update user profile (uses set with merge so it works if doc doesn't exist)
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(updates, SetOptions(merge: true));
  }

  /// Delete user profile
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  /// Stream user profile for real-time updates
  Stream<AppUser?> watchUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final data = {'id': doc.id, ...doc.data()!};
      return AppUserMapper.fromMap(data);
    });
  }

  /// Add a custom category (premium feature)
  Future<void> addCustomCategory(String userId, String categoryName) async {
    await _firestore.collection('users').doc(userId).update({
      'customCategories': FieldValue.arrayUnion([categoryName]),
    });
  }

  /// Remove a custom category (premium feature)
  Future<void> removeCustomCategory(String userId, String categoryName) async {
    await _firestore.collection('users').doc(userId).update({
      'customCategories': FieldValue.arrayRemove([categoryName]),
    });
  }

  /// Rename a custom category (premium feature)
  Future<void> renameCustomCategory(
    String userId,
    String oldName,
    String newName,
  ) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final categories = List<String>.from(data['customCategories'] ?? []);
    final index = categories.indexOf(oldName);
    if (index != -1) {
      categories[index] = newName;
      await _firestore.collection('users').doc(userId).update({
        'customCategories': categories,
      });
    }
  }
}

@riverpod
UserService userService(Ref ref) {
  return UserService();
}

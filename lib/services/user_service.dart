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

    return AppUserMapper.fromMap(doc.data()!);
  }

  /// Save user profile to Firestore
  Future<void> saveUser(AppUser profile) async {
    await _firestore.collection('users').doc(profile.id).set(profile.toMap());
  }

  /// Update user profile
  Future<void> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection('users').doc(userId).update(updates);
  }

  /// Delete user profile
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}

@riverpod
UserService userService(Ref ref) {
  return UserService();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/customer_profile.dart';

class CustomerFailure implements Exception {
  const CustomerFailure(this.code);
  final String code;
}

String? validateCustomerName(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.length < 2 || normalized.length > 80) return 'invalidName';
  if (!RegExp(r"^[\p{L}][\p{L}\p{M} .'-]*$", unicode: true)
      .hasMatch(normalized)) {
    return 'invalidName';
  }
  return null;
}

String? normalizeIndianPhone(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('91') && digits.length == 12) {
    digits = digits.substring(2);
  }
  if (digits.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
    return null;
  }
  return '+91$digits';
}

abstract interface class CustomerRepository {
  Future<CustomerProfile?> currentProfile();
  Future<CustomerProfile?> restoreSession({
    required String name,
    required String phoneNumber,
  });
  Future<CustomerProfile> saveVerifiedCustomer({
    required User user,
    required String name,
    required String phoneNumber,
  });
  Future<void> signOut();
}

class FirebaseCustomerRepository implements CustomerRepository {
  FirebaseCustomerRepository(this._db, this._auth);
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  @override
  Future<CustomerProfile?> currentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final document = await _db.collection('users').doc(user.uid).get();
    if (!document.exists) return null;
    final profile = CustomerProfile.fromFirestore(document);
    return profile.isActive && profile.phoneVerified ? profile : null;
  }

  @override
  Future<CustomerProfile?> restoreSession({
    required String name,
    required String phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.phoneNumber != phoneNumber) return null;
    final document = await _db.collection('users').doc(user.uid).get();
    if (!document.exists) return null;
    final profile = CustomerProfile.fromFirestore(document);
    if (!profile.isActive ||
        !profile.phoneVerified ||
        profile.phoneNumber != phoneNumber) {
      return null;
    }
    final normalizedName = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedName != profile.name) {
      await document.reference.update(<String, Object?>{
        'name': normalizedName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return CustomerProfile(
        uid: profile.uid,
        name: normalizedName,
        phoneNumber: profile.phoneNumber,
        phoneVerified: profile.phoneVerified,
        isActive: profile.isActive,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );
    }
    return profile;
  }

  @override
  Future<CustomerProfile> saveVerifiedCustomer({
    required User user,
    required String name,
    required String phoneNumber,
  }) async {
    if (user.phoneNumber != phoneNumber) {
      throw const CustomerFailure('phoneMismatch');
    }
    final reference = _db.collection('users').doc(user.uid);
    final existing = await reference.get();
    final now = FieldValue.serverTimestamp();
    await reference.set(<String, Object?>{
      'uid': user.uid,
      'name': name.trim().replaceAll(RegExp(r'\s+'), ' '),
      'phoneNumber': phoneNumber,
      'role': 'customer',
      'phoneVerified': true,
      'isActive': true,
      if (!existing.exists) 'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
    final saved = await reference.get();
    return CustomerProfile.fromFirestore(saved);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

class UnavailableCustomerRepository implements CustomerRepository {
  const UnavailableCustomerRepository();
  @override
  Future<CustomerProfile?> currentProfile() async => null;
  @override
  Future<CustomerProfile?> restoreSession(
          {required String name, required String phoneNumber}) async =>
      null;
  @override
  Future<CustomerProfile> saveVerifiedCustomer(
          {required User user,
          required String name,
          required String phoneNumber}) =>
      throw const CustomerFailure('firebaseUnavailable');
  @override
  Future<void> signOut() async {}
}

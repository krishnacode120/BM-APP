import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_identity.dart';
import '../models/customer_profile.dart';
import '../services/supabase_auth_service.dart';
import 'customer_repository.dart';

class SupabaseCustomerRepository implements CustomerRepository {
  SupabaseCustomerRepository(this.client);
  final SupabaseClient client;

  Future<AuthIdentity?> _verifiedIdentity() async {
    if (client.auth.currentSession == null) return null;
    final user = (await client.auth.getUser()).user;
    if (user == null || client.auth.currentUser?.id != user.id) return null;
    final identity = supabaseIdentity(user);
    return identity.phoneNumber == null ? null : identity;
  }

  Future<CustomerProfile?> _profile(AuthIdentity identity) async {
    final row = await client
        .from('profiles')
        .select()
        .eq('id', identity.uid)
        .maybeSingle();
    if (client.auth.currentUser?.id != identity.uid || row == null) return null;
    if (row['phone_verified'] != true ||
        row['is_active'] != true ||
        row['phone_number'] != identity.phoneNumber) {
      throw const CustomerFailure('phoneMismatch');
    }
    return CustomerProfile(
        uid: row['id'] as String,
        name: row['name'] as String,
        phoneNumber: row['phone_number'] as String,
        phoneVerified: true,
        isActive: true,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String));
  }

  @override
  Future<CustomerProfile?> currentProfile() async {
    final identity = await _verifiedIdentity();
    if (identity == null) return null;
    final profile = await _profile(identity);
    return profile == null || validateCustomerName(profile.name) != null
        ? null
        : profile;
  }

  @override
  Future<CustomerProfile?> restoreSession(
      {required String name, required String phoneNumber}) async {
    final identity = await _verifiedIdentity();
    if (identity == null || identity.phoneNumber != phoneNumber) return null;
    return saveVerifiedCustomer(
        user: identity, name: name, phoneNumber: phoneNumber);
  }

  @override
  Future<CustomerProfile> saveVerifiedCustomer(
      {required AuthIdentity user,
      required String name,
      required String phoneNumber}) async {
    if (validateCustomerName(name) != null) {
      throw const CustomerFailure('invalidName');
    }
    final identity = await _verifiedIdentity();
    if (identity == null ||
        identity.uid != user.uid ||
        identity.phoneNumber != phoneNumber) {
      throw const CustomerFailure('phoneMismatch');
    }
    // Auth's server trigger creates identity fields; clients can only rename.
    final before = await _profile(identity);
    if (before == null) throw const CustomerFailure('customerInactive');
    await client
        .from('profiles')
        .update({'name': name.trim().replaceAll(RegExp(r'\s+'), ' ')}).eq(
            'id', identity.uid);
    final profile = await _profile(identity);
    if (profile == null) throw const CustomerFailure('customerProfileFailed');
    return profile;
  }

  @override
  Future<void> signOut() => client.auth.signOut(scope: SignOutScope.local);
}

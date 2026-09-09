import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/auth_identity.dart';
import 'auth_service.dart';

AuthIdentity supabaseIdentity(sb.User user) => AuthIdentity(
    uid: user.id,
    phoneNumber: user.phoneConfirmedAt == null || (user.phone?.isEmpty ?? true)
        ? null
        : '+${user.phone!.replaceFirst(RegExp(r'^\+'), '')}');

String supabaseAuthError(Object error) {
  if (error is TimeoutException) return 'otpRequestTimeout';
  if (error is sb.AuthException) {
    return switch (error.code) {
      'otp_expired' || 'otp_disabled' => 'invalidOtp',
      'over_sms_send_rate_limit' ||
      'over_request_rate_limit' =>
        'too-many-requests',
      'sms_send_failed' ||
      'phone_provider_disabled' ||
      'provider_disabled' =>
        'operation-not-allowed',
      'phone_exists' || 'validation_failed' => 'invalidPhone',
      'user_banned' => 'customerInactive',
      _ => 'otpRequestFailed',
    };
  }
  return 'otpRequestFailed';
}

class SupabasePhoneAuthService implements AuthService {
  SupabasePhoneAuthService(this.client);
  final sb.SupabaseClient client;

  @override
  Stream<PhoneVerificationEvent> requestOtp(
      {required String phoneNumber, bool forceResend = false}) async* {
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phoneNumber)) {
      throw const AuthFailure('invalidPhone');
    }
    try {
      // Supabase owns code generation, expiry and rate limits. No local OTP.
      await client.auth
          .signInWithOtp(phone: phoneNumber)
          .timeout(const Duration(seconds: 30));
      // Opaque to the controller; Supabase verification is scoped to this phone.
      yield PhoneCodeSentEvent(phoneNumber);
    } catch (error) {
      throw AuthFailure(supabaseAuthError(error));
    }
  }

  @override
  Future<AuthSessionResult> verifyOtp(
      {required String verificationId, required String smsCode}) async {
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(verificationId) ||
        !RegExp(r'^\d{6}$').hasMatch(smsCode)) {
      throw const AuthFailure('invalidOtp');
    }
    try {
      final response = await client.auth.verifyOTP(
          phone: verificationId, token: smsCode, type: sb.OtpType.sms);
      final user = response.user;
      if (user == null ||
          response.session == null ||
          supabaseIdentity(user).phoneNumber != verificationId) {
        throw const AuthFailure('invalidOtp');
      }
      return AuthSessionResult(supabaseIdentity(user));
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw AuthFailure(supabaseAuthError(error));
    }
  }
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_identity.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.code);
  final String code;
}

sealed class PhoneVerificationEvent {
  const PhoneVerificationEvent();
}

class PhoneCodeSentEvent extends PhoneVerificationEvent {
  const PhoneCodeSentEvent(this.verificationId);
  final String verificationId;
}

class PhoneVerified extends PhoneVerificationEvent {
  const PhoneVerified(this.credential);
  final AuthSessionResult credential;
}

abstract interface class AuthService {
  Stream<PhoneVerificationEvent> requestOtp({
    required String phoneNumber,
    bool forceResend = false,
  });
  Future<AuthSessionResult> verifyOtp(
      {required String verificationId, required String smsCode});
}

class FirebasePhoneAuthService implements AuthService {
  FirebasePhoneAuthService(this._auth,
      {this.requestTimeout = const Duration(seconds: 90)});
  final FirebaseAuth _auth;
  final Duration requestTimeout;
  String? _resendPhone;
  int? _resendToken;

  @override
  Stream<PhoneVerificationEvent> requestOtp({
    required String phoneNumber,
    bool forceResend = false,
  }) {
    late StreamController<PhoneVerificationEvent> controller;
    Timer? timeout;
    var active = true;
    var codeSent = false;
    var completing = false;

    void close() {
      if (!active) return;
      active = false;
      timeout?.cancel();
      unawaited(controller.close());
    }

    void fail(Object error) {
      if (!active) return;
      controller.addError(error is FirebaseAuthException
          ? AuthFailure(error.code)
          : error is AuthFailure
              ? error
              : const AuthFailure('otpRequestFailed'));
      close();
    }

    Future<void> start() async {
      timeout = Timer(requestTimeout, () {
        if (codeSent) {
          close();
        } else {
          fail(const AuthFailure('otpRequestTimeout'));
        }
      });
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          forceResendingToken:
              forceResend && _resendPhone == phoneNumber ? _resendToken : null,
          verificationCompleted: (credential) async {
            if (!active || completing) return;
            completing = true;
            try {
              final result = await _auth.signInWithCredential(credential);
              if (!active) return;
              if (result.user == null) {
                fail(const AuthFailure('invalidOtp'));
                return;
              }
              controller.add(PhoneVerified(AuthSessionResult(AuthIdentity(
                  uid: result.user!.uid,
                  phoneNumber: result.user!.phoneNumber))));
              close();
            } catch (error) {
              fail(error);
            }
          },
          verificationFailed: fail,
          codeSent: (verificationId, token) {
            if (!active || completing) return;
            _resendPhone = phoneNumber;
            _resendToken = token;
            codeSent = true;
            controller.add(PhoneCodeSentEvent(verificationId));
          },
          codeAutoRetrievalTimeout: (verificationId) {
            if (!active || completing) return;
            // Native auto retrieval expiring does not invalidate manual entry.
            if (!codeSent && verificationId.isNotEmpty) {
              controller.add(PhoneCodeSentEvent(verificationId));
            }
            close();
          },
        );
      } catch (error) {
        fail(error);
      }
    }

    controller = StreamController<PhoneVerificationEvent>(
      onListen: () => unawaited(start()),
      onCancel: () {
        active = false;
        timeout?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<AuthSessionResult> verifyOtp(
      {required String verificationId, required String smsCode}) async {
    if (verificationId.isEmpty || !RegExp(r'^\d{6}$').hasMatch(smsCode)) {
      throw const AuthFailure('invalidOtp');
    }
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      final result = await _auth.signInWithCredential(credential);
      if (result.user == null) throw const AuthFailure('invalidOtp');
      return AuthSessionResult(AuthIdentity(
          uid: result.user!.uid, phoneNumber: result.user!.phoneNumber));
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }
}

class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  @override
  Stream<PhoneVerificationEvent> requestOtp({
    required String phoneNumber,
    bool forceResend = false,
  }) =>
      Stream<PhoneVerificationEvent>.error(
          const AuthFailure('firebaseUnavailable'));

  @override
  Future<AuthSessionResult> verifyOtp(
          {required String verificationId, required String smsCode}) =>
      Future<AuthSessionResult>.error(const AuthFailure('firebaseUnavailable'));
}

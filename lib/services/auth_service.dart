import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.code);
  final String code;
}

abstract interface class AuthService {
  Future<void> requestOtp(
      {required String phoneNumber,
      required void Function(String verificationId) onCodeSent});
  Future<UserCredential> verifyOtp(
      {required String verificationId, required String smsCode});
}

class FirebasePhoneAuthService implements AuthService {
  FirebasePhoneAuthService(this._auth);
  final FirebaseAuth _auth;

  @override
  Future<void> requestOtp(
      {required String phoneNumber,
      required void Function(String verificationId) onCodeSent}) {
    final completer = Completer<void>();
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential _) {},
      verificationFailed: (FirebaseAuthException error) {
        if (!completer.isCompleted) {
          completer.completeError(AuthFailure(error.code));
        }
      },
      codeSent: (String verificationId, int? _) {
        onCodeSent(verificationId);
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  @override
  Future<UserCredential> verifyOtp(
      {required String verificationId, required String smsCode}) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }
}

class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  @override
  Future<void> requestOtp(
          {required String phoneNumber,
          required void Function(String verificationId) onCodeSent}) =>
      Future<void>.error(const AuthFailure('firebaseUnavailable'));

  @override
  Future<UserCredential> verifyOtp(
          {required String verificationId, required String smsCode}) =>
      Future<UserCredential>.error(const AuthFailure('firebaseUnavailable'));
}

import 'package:firebase_auth/firebase_auth.dart';

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
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential _) {},
      verificationFailed: (FirebaseAuthException error) => throw error,
      codeSent: (String verificationId, int? _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<UserCredential> verifyOtp(
      {required String verificationId, required String smsCode}) {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return _auth.signInWithCredential(credential);
  }
}

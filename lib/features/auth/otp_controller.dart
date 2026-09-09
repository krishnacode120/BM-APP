import 'dart:async';

import '../../models/auth_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/customer_repository.dart';
import '../../services/auth_service.dart';
import 'auth_providers.dart';

class OtpArguments {
  const OtpArguments(
      {required this.phone,
      required this.fullName,
      required this.createAccount});
  final String phone;
  final String fullName;
  final bool createAccount;
}

class OtpState {
  const OtpState(
      {this.verificationId,
      this.requesting = false,
      this.verifying = false,
      this.completed = false,
      this.errorCode});
  final String? verificationId;
  final bool requesting;
  final bool verifying;
  final bool completed;
  final String? errorCode;
  bool get busy => requesting || verifying;
}

final otpControllerProvider = StateNotifierProvider.autoDispose
    .family<OtpController, OtpState, OtpArguments>((ref, arguments) =>
        OtpController(ref.watch(authServiceProvider),
            ref.watch(customerRepositoryProvider), arguments));

class OtpController extends StateNotifier<OtpState> {
  OtpController(this._auth, this._customers, this.arguments)
      : super(const OtpState());
  final AuthService _auth;
  final CustomerRepository _customers;
  final OtpArguments arguments;
  StreamSubscription<PhoneVerificationEvent>? _subscription;
  int _generation = 0;

  Future<void> request({bool resend = false}) async {
    if (state.busy || state.completed) return;
    final generation = ++_generation;
    state = const OtpState(requesting: true);
    await _subscription?.cancel();
    if (!mounted || generation != _generation) return;
    try {
      _subscription = _auth
          .requestOtp(phoneNumber: arguments.phone, forceResend: resend)
          .listen(
              (event) {
                if (!mounted || generation != _generation || state.verifying) {
                  return;
                }
                switch (event) {
                  case PhoneCodeSentEvent(:final verificationId):
                    if (verificationId.isEmpty) {
                      _fail(const AuthFailure('otpRequestFailed'), generation);
                    } else {
                      state = OtpState(verificationId: verificationId);
                    }
                  case PhoneVerified(:final credential):
                    unawaited(_complete(credential, generation));
                }
              },
              onError: (Object error) => _fail(error, generation),
              onDone: () {
                if (mounted && generation == _generation && state.requesting) {
                  _fail(const AuthFailure('otpRequestTimeout'), generation);
                }
              });
    } catch (error) {
      _fail(error, generation);
    }
  }

  Future<void> verify(String code) async {
    if (state.busy || state.completed) return;
    final id = state.verificationId;
    if (id == null || !RegExp(r'^\d{6}$').hasMatch(code.trim())) {
      state = OtpState(verificationId: id, errorCode: 'invalidOtp');
      return;
    }
    final generation = ++_generation;
    state = OtpState(verificationId: id, verifying: true);
    await _subscription?.cancel();
    if (!mounted) return;
    try {
      final credential =
          await _auth.verifyOtp(verificationId: id, smsCode: code.trim());
      if (!mounted || generation != _generation) return;
      await _complete(credential, generation);
    } catch (error) {
      _fail(error, generation);
    }
  }

  Future<void> _complete(AuthSessionResult credential, int generation) async {
    if (!mounted || generation != _generation || state.completed) return;
    final id = state.verificationId;
    state = OtpState(verificationId: id, verifying: true);
    try {
      final user = credential.user;
      if (user == null) throw const AuthFailure('invalidOtp');
      await _customers.saveVerifiedCustomer(
          user: user, name: arguments.fullName, phoneNumber: arguments.phone);
      if (mounted && generation == _generation) {
        state = const OtpState(completed: true);
      }
    } catch (error) {
      _fail(
          error is AuthFailure || error is CustomerFailure
              ? error
              : const AuthFailure('customerProfileFailed'),
          generation);
    }
  }

  void _fail(Object error, int generation) {
    if (!mounted || generation != _generation || state.completed) return;
    final code = switch (error) {
      AuthFailure(:final code) => code,
      CustomerFailure(:final code) => code,
      _ => 'otpRequestFailed',
    };
    state = OtpState(verificationId: state.verificationId, errorCode: code);
  }

  @override
  void dispose() {
    _generation++;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}

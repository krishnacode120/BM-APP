import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import 'auth_providers.dart';

class OtpArguments {
  const OtpArguments({
    required this.phone,
    required this.verificationId,
    required this.fullName,
    required this.createAccount,
  });
  final String phone;
  final String verificationId;
  final String fullName;
  final bool createAccount;
}

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({required this.arguments, super.key});
  final OtpArguments arguments;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final code = TextEditingController();
  late String verificationId = widget.arguments.verificationId;
  bool isVerifying = false;
  bool isResending = false;
  String? errorCode;
  int resendSeconds = 30;
  Timer? resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(t.verifyPhone(widget.arguments.phone),
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(t.otpInstruction),
                  const SizedBox(height: 28),
                  TextField(
                      controller: code,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration:
                          const InputDecoration(hintText: '• • • • • •')),
                  if (errorCode != null)
                    Text(t.authError(errorCode!),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  TextButton(
                      onPressed:
                          isResending || resendSeconds > 0 ? null : _resend,
                      child: Text(isResending
                          ? t.loading
                          : resendSeconds > 0
                              ? t.resendOtpIn(resendSeconds)
                              : t.resendOtp)),
                  const Spacer(),
                  FilledButton(
                      onPressed: isVerifying ? null : _verify,
                      child: isVerifying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(t.verify))
                ])));
  }

  Future<void> _verify() async {
    if (code.text.trim().length != 6) {
      setState(() => errorCode = 'invalidOtp');
      return;
    }
    setState(() {
      isVerifying = true;
      errorCode = null;
    });
    try {
      final credential = await ref
          .read(authServiceProvider)
          .verifyOtp(verificationId: verificationId, smsCode: code.text.trim());
      final user = credential.user;
      if (user != null && Firebase.apps.isNotEmpty) {
        await ref.read(customerRepositoryProvider).saveVerifiedCustomer(
              user: user,
              name: widget.arguments.fullName,
              phoneNumber: widget.arguments.phone,
            );
        ref.invalidate(currentCustomerProvider);
      }
      if (mounted) context.go('/home');
    } on AuthFailure catch (error) {
      if (mounted) setState(() => errorCode = error.code);
    } catch (_) {
      if (mounted) setState(() => errorCode = 'invalidOtp');
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      isResending = true;
      errorCode = null;
    });
    try {
      await ref.read(authServiceProvider).requestOtp(
          phoneNumber: widget.arguments.phone,
          onCodeSent: (value) {
            verificationId = value;
            if (mounted) _startResendCountdown();
          });
    } on AuthFailure catch (error) {
      if (mounted) setState(() => errorCode = error.code);
    } catch (_) {
      if (mounted) setState(() => errorCode = 'otpRequestFailed');
    } finally {
      if (mounted) setState(() => isResending = false);
    }
  }

  void _startResendCountdown() {
    resendTimer?.cancel();
    setState(() => resendSeconds = 30);
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => resendSeconds = 0);
        return;
      }
      setState(() => resendSeconds--);
    });
  }
}

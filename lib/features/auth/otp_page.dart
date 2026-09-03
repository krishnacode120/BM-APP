import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import 'auth_providers.dart';

class OtpArguments {
  const OtpArguments({required this.phone, required this.verificationId});
  final String phone;
  final String verificationId;
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

  @override
  void dispose() {
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
                      onPressed: isResending ? null : _resend,
                      child: Text(isResending ? t.loading : t.resendOtp)),
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
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'phoneNumber': user.phoneNumber ?? widget.arguments.phone,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } on FirebaseException {
          // The profile is a display mirror; login authority stays in Auth.
        }
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
          });
    } on AuthFailure catch (error) {
      if (mounted) setState(() => errorCode = error.code);
    } catch (_) {
      if (mounted) setState(() => errorCode = 'otpRequestFailed');
    } finally {
      if (mounted) setState(() => isResending = false);
    }
  }
}

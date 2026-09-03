import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import 'auth_providers.dart';
import 'otp_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final phone = TextEditingController();
  bool isSending = false;
  String? errorCode;

  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(title: const Text('BM')),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 52),
                      Text(t.phoneLogin,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(t.enterPhone),
                      const SizedBox(height: 28),
                      TextField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              prefixText: '+91 ', hintText: '98765 43210')),
                      const Spacer(),
                      if (errorCode != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(t.authError(errorCode!),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                      FilledButton(
                          onPressed: isSending ? null : _sendOtp,
                          child: isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : Text(t.continueText)),
                    ]))));
  }

  Future<void> _sendOtp() async {
    final digits = phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      setState(() => errorCode = 'invalidPhone');
      return;
    }
    setState(() {
      isSending = true;
      errorCode = null;
    });
    try {
      await ref.read(authServiceProvider).requestOtp(
          phoneNumber: '+91$digits',
          onCodeSent: (verificationId) {
            if (mounted) {
              context.push('/otp',
                  extra: OtpArguments(
                      phone: '+91$digits', verificationId: verificationId));
            }
          });
    } on AuthFailure catch (error) {
      if (mounted) setState(() => errorCode = error.code);
    } catch (_) {
      if (mounted) setState(() => errorCode = 'otpRequestFailed');
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }
}

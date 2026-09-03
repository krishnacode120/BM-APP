import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
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
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const Center(child: BmLogo(width: 104)),
                              const SizedBox(height: 42),
                              Text(t.welcome,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              const SizedBox(height: 8),
                              Text(t.welcomeSubtitle,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 32),
                              Text(t.phoneLogin,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 10),
                              TextField(
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  autofillHints: const <String>[
                                    AutofillHints.telephoneNumber
                                  ],
                                  decoration: InputDecoration(
                                      labelText: t.phoneNumber,
                                      prefixIcon:
                                          const Icon(Icons.phone_outlined),
                                      prefixText: '+91 ',
                                      hintText: '98765 43210')),
                              const SizedBox(height: 24),
                              if (errorCode != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(t.authError(errorCode!),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                                ),
                              BmPrimaryButton(
                                  label: t.continueText,
                                  icon: Icons.arrow_forward_rounded,
                                  loading: isSending,
                                  onPressed: isSending ? null : _sendOtp),
                              if (Firebase.apps.isEmpty) ...<Widget>[
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => context.go('/home'),
                                  icon: const Icon(Icons.visibility_outlined),
                                  label: Text(t.continueText),
                                ),
                                const SizedBox(height: 8),
                                Text(t.firebaseUnavailable,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: BmColors.secondaryText,
                                        fontSize: 12)),
                              ],
                              const SizedBox(height: 18),
                              TextButton.icon(
                                onPressed: () => context.push('/language'),
                                icon: const Icon(Icons.translate_rounded),
                                label: Text(t.language),
                              ),
                            ]))))));
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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../../repositories/customer_repository.dart';
import '../../services/auth_service.dart';
import 'auth_providers.dart';
import 'otp_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => const _CustomerAccessForm();
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) => const _CustomerAccessForm(signUp: true);
}

class _CustomerAccessForm extends ConsumerStatefulWidget {
  const _CustomerAccessForm({this.signUp = false});
  final bool signUp;

  @override
  ConsumerState<_CustomerAccessForm> createState() =>
      _CustomerAccessFormState();
}

class _CustomerAccessFormState extends ConsumerState<_CustomerAccessForm> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isSending = false;
  String? errorCode;

  @override
  void dispose() {
    name.dispose();
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
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (!widget.signUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          key: const Key('admin-login-link'),
                          onPressed: () => context.push('/admin/login'),
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          label: Text(t.adminLogin),
                        ),
                      ),
                    const Center(child: BmLogo(width: 104)),
                    const SizedBox(height: 38),
                    Text(
                      widget.signUp ? t.createAccount : t.welcome,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.signUp ? t.signUpSubtitle : t.simpleLoginSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: name,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const <String>[AutofillHints.name],
                      decoration: InputDecoration(
                        labelText: t.fullName,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) =>
                          validateCustomerName(value ?? '') == null
                              ? null
                              : t.invalidName,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      autofillHints: const <String>[
                        AutofillHints.telephoneNumber
                      ],
                      decoration: InputDecoration(
                        labelText: t.phoneNumber,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        prefixText: '+91 ',
                        hintText: '98765 43210',
                      ),
                      validator: (value) =>
                          normalizeIndianPhone(value ?? '') == null
                              ? t.authError('invalidPhone')
                              : null,
                    ),
                    const SizedBox(height: 20),
                    if (errorCode != null) ...<Widget>[
                      Text(
                        t.authError(errorCode!),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 12),
                    ],
                    BmPrimaryButton(
                      label: widget.signUp ? t.sendOtp : t.continueText,
                      icon: Icons.arrow_forward_rounded,
                      loading: isSending,
                      onPressed: isSending ? null : _continue,
                    ),
                    if (!widget.signUp && Firebase.apps.isEmpty) ...<Widget>[
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(t.previewCatalog),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.firebaseUnavailable,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: BmColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => widget.signUp
                          ? context.go('/login')
                          : context.push('/signup'),
                      child: Text(
                          widget.signUp ? t.alreadyCustomer : t.newCustomer),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/language'),
                      icon: const Icon(Icons.translate_rounded),
                      label: Text(t.language),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (formKey.currentState?.validate() != true) return;
    final normalizedPhone = normalizeIndianPhone(phone.text)!;
    final normalizedName = name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    setState(() {
      isSending = true;
      errorCode = null;
    });
    try {
      if (!widget.signUp) {
        final restored =
            await ref.read(customerRepositoryProvider).restoreSession(
                  name: normalizedName,
                  phoneNumber: normalizedPhone,
                );
        if (restored != null) {
          ref.invalidate(currentCustomerProvider);
          if (mounted) context.go('/home');
          return;
        }
      }
      await ref.read(authServiceProvider).requestOtp(
            phoneNumber: normalizedPhone,
            onCodeSent: (verificationId) {
              if (!mounted) return;
              context.push(
                '/otp',
                extra: OtpArguments(
                  phone: normalizedPhone,
                  verificationId: verificationId,
                  fullName: normalizedName,
                  createAccount: widget.signUp,
                ),
              );
            },
          );
    } on AuthFailure catch (error) {
      if (mounted) setState(() => errorCode = error.code);
    } on CustomerFailure catch (error) {
      if (mounted) setState(() => errorCode = error.code);
    } catch (_) {
      if (mounted) setState(() => errorCode = 'otpRequestFailed');
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }
}

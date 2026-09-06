import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../../repositories/admin_repository.dart';
import 'admin_providers.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (loading || !(formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ref.read(adminSignInProvider)(
        email: email.text.trim(),
        password: password.text,
      );
      if (!mounted) return;
      ref.invalidate(adminAccessProvider);
      context.go('/admin');
    } on AdminFailure catch (exception) {
      if (mounted) {
        setState(() => error =
            AppLocalizations.of(context).adminLoginError(exception.code));
      }
    } catch (_) {
      if (mounted) {
        setState(() =>
            error = AppLocalizations.of(context).adminLoginError('unknown'));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                  child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Center(child: BmLogo(width: 108)),
                          const SizedBox(height: 32),
                          Text(t.adminLogin,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: email,
                            enabled: !loading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            autofillHints: const <String>[
                              AutofillHints.username
                            ],
                            validator: (value) {
                              final address = value?.trim() ?? '';
                              if (address.isEmpty) return t.requiredField;
                              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(address)) {
                                return t.adminLoginError('invalid-email');
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: t.email,
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: password,
                            enabled: !loading,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            validator: (value) => value == null || value.isEmpty
                                ? t.requiredField
                                : null,
                            autofillHints: const <String>[
                              AutofillHints.password
                            ],
                            decoration: InputDecoration(
                              labelText: t.password,
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          if (error != null) ...<Widget>[
                            const SizedBox(height: 12),
                            Semantics(
                                liveRegion: true,
                                child: Text(error!,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error))),
                          ],
                          const SizedBox(height: 20),
                          BmPrimaryButton(
                              label: t.continueText,
                              loading: loading,
                              onPressed: loading ? null : _login),
                        ],
                      ))),
            ),
          ),
        ),
      ),
    );
  }
}

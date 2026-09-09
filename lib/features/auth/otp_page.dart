import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../core/config/backend_config.dart';
import 'auth_providers.dart';
import 'otp_controller.dart';
export 'otp_controller.dart' show OtpArguments;

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({required this.arguments, super.key});
  final OtpArguments arguments;
  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final code = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(otpControllerProvider(widget.arguments).notifier).request();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _resendTimer?.cancel();
    final seconds = ref.read(backendConfigProvider).isSupabase ? 60 : 30;
    final deadline = DateTime.now().add(Duration(seconds: seconds));
    setState(() => _resendSeconds = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = deadline.difference(DateTime.now()).inMilliseconds;
      setState(() =>
          _resendSeconds = remaining <= 0 ? 0 : (remaining / 1000).ceil());
      if (_resendSeconds == 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = otpControllerProvider(widget.arguments);
    final state = ref.watch(provider);
    ref.listen<OtpState>(provider, (previous, next) {
      if (previous?.requesting != true && next.requesting) _startCountdown();
      if (next.completed && previous?.completed != true) {
        ref.invalidate(currentCustomerProvider);
        context.go('/home');
      }
    });
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.verifyPhone(widget.arguments.phone),
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(t.otpInstruction),
                  const SizedBox(height: 28),
                  TextField(
                      controller: code,
                      enabled: !state.busy,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      onSubmitted: (_) =>
                          ref.read(provider.notifier).verify(code.text),
                      decoration: InputDecoration(
                          labelText: t.otpCode, hintText: '• • • • • •')),
                  if (state.errorCode != null)
                    Semantics(
                        liveRegion: true,
                        child: Text(t.authError(state.errorCode!),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                  TextButton(
                      onPressed: state.busy || _resendSeconds > 0
                          ? null
                          : () {
                              code.clear();
                              ref.read(provider.notifier).request(resend: true);
                            },
                      child: Text(state.requesting
                          ? t.loading
                          : _resendSeconds > 0
                              ? t.resendOtpIn(_resendSeconds)
                              : t.resendOtp)),
                  const SizedBox(height: 24),
                  FilledButton(
                      onPressed: state.busy || state.verificationId == null
                          ? null
                          : () => ref.read(provider.notifier).verify(code.text),
                      child: Text(state.busy ? t.loading : t.verify)),
                ])),
      ))),
    );
  }
}

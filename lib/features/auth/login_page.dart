import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phone = TextEditingController();
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
                      FilledButton(
                          onPressed: () {
                            if (phone.text.trim().length >= 10) {
                              context.push('/otp', extra: phone.text.trim());
                            }
                          },
                          child: Text(t.continueText)),
                    ]))));
  }
}

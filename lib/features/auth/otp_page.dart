import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({required this.phone, super.key});
  final String phone;
  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('Verify $phone',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                      'Firebase Phone Authentication will send a one-time code after Firebase is configured.'),
                  const SizedBox(height: 28),
                  const TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(hintText: '• • • • • •')),
                  const Spacer(),
                  FilledButton(
                      onPressed: () => context.go('/home'),
                      child: Text(t.verify))
                ])));
  }
}

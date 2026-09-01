import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        CircleAvatar(
            radius: 42,
            child: Text('BM',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        SizedBox(height: 16),
        Text('Building Materials', style: TextStyle(fontSize: 18))
      ])));
}

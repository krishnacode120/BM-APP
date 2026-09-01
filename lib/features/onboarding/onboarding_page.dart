import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int page = 0;
  final PageController controller = PageController();
  final List<String> slides = <String>[
    'Find construction materials easily',
    'Get prices based on your location',
    'Order materials easily',
    'Track your orders',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: slides.length,
                  onPageChanged: (int value) => setState(() => page = value),
                  itemBuilder: (_, int index) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.construction_outlined,
                            size: 108,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 28),
                        Text(slides[index],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                      slides.length,
                      (int index) => Container(
                          margin: const EdgeInsets.all(4),
                          width: index == page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: index == page
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8))))),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (page == slides.length - 1) {
                    context.go('/login');
                  } else {
                    controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut);
                  }
                },
                child: Text(
                    page == slides.length - 1 ? t.getStarted : t.continueText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

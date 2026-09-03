import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_preferences.dart';
import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final selected = ref.watch(appPreferencesProvider).locale.languageCode;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Spacer(),
                  const Center(child: BmLogo(width: 116)),
                  const SizedBox(height: 40),
                  Text(t.chooseLanguage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(t.languageHelp, textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  _LanguageCard(
                    title: t.english,
                    subtitle: 'Continue in English',
                    selected: selected == 'en',
                    onTap: () => ref
                        .read(appPreferencesProvider.notifier)
                        .selectLanguage('en'),
                  ),
                  const SizedBox(height: 12),
                  _LanguageCard(
                    title: t.tamil,
                    subtitle: 'தமிழில் தொடரவும்',
                    selected: selected == 'ta',
                    onTap: () => ref
                        .read(appPreferencesProvider.notifier)
                        .selectLanguage('ta'),
                  ),
                  const Spacer(),
                  BmPrimaryButton(
                    label: t.continueText,
                    onPressed: () async {
                      if (!ref
                          .read(appPreferencesProvider)
                          .hasSelectedLanguage) {
                        await ref
                            .read(appPreferencesProvider.notifier)
                            .selectLanguage('en');
                      }
                      if (!context.mounted) return;
                      final ready =
                          ref.read(appPreferencesProvider).onboardingComplete;
                      if (ready) {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      } else {
                        context.go('/onboarding');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: selected ? BmColors.lightOrange : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? BmColors.orange : BmColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(title.characters.first,
                      style: const TextStyle(
                          color: BmColors.orange, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(subtitle),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? BmColors.orange : BmColors.secondaryText,
                ),
              ],
            ),
          ),
        ),
      );
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int page = 0;
  final PageController controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appPreferencesProvider.notifier).completeOnboarding();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final slides = <({String title, String body, IconData icon})>[
      (
        title: t.onboardingFindTitle,
        body: t.onboardingFindBody,
        icon: Icons.grid_view_rounded
      ),
      (
        title: t.onboardingPriceTitle,
        body: t.onboardingPriceBody,
        icon: Icons.location_on_outlined
      ),
      (
        title: t.onboardingTrackTitle,
        body: t.onboardingTrackBody,
        icon: Icons.local_shipping_outlined
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: <Widget>[
                  const BmLogo(width: 72),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: Text(t.skip)),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (value) => setState(() => page = value),
                itemBuilder: (_, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: <Widget>[
                        const Spacer(),
                        Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: BmColors.peach,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: index == 0
                              ? const BmImage(
                                  source:
                                      'assets/images/banners/materials_hero.png',
                                  fit: BoxFit.cover,
                                  borderRadius: 28,
                                )
                              : Icon(slide.icon,
                                  size: 116, color: BmColors.orange),
                        ),
                        const SizedBox(height: 32),
                        Text(slide.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text(slide.body, textAlign: TextAlign.center),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.all(4),
                  width: index == page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == page ? BmColors.orange : BmColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: BmPrimaryButton(
                  label: page == slides.length - 1 ? t.getStarted : t.next,
                  onPressed: page == slides.length - 1
                      ? _finish
                      : () => controller.nextPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

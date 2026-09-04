import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_preferences.dart';
import '../../core/theme/bm_theme.dart';
import '../../core/widgets/bm_components.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..forward();
  Timer? _timer;
  bool _minimumElapsed = false;
  bool _navigated = false;
  bool _checkingSession = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1250), () {
      _minimumElapsed = true;
      _routeIfReady();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  Future<void> _routeIfReady() async {
    final preferences = ref.read(appPreferencesProvider);
    if (!mounted ||
        _navigated ||
        _checkingSession ||
        !_minimumElapsed ||
        !preferences.isLoaded) {
      return;
    }
    if (!preferences.hasSelectedLanguage || !preferences.onboardingComplete) {
      _navigated = true;
      context
          .go(!preferences.hasSelectedLanguage ? '/language' : '/onboarding');
      return;
    }
    _checkingSession = true;
    try {
      final customer = await ref.read(currentCustomerProvider.future);
      if (!mounted || _navigated) return;
      _navigated = true;
      context.go(customer == null ? '/login' : '/home');
    } catch (_) {
      if (!mounted || _navigated) return;
      _navigated = true;
      context.go('/login');
    } finally {
      _checkingSession = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppPreferenceState>(appPreferencesProvider, (_, __) {
      _routeIfReady();
    });
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: BmColors.peach,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Opacity(
              opacity: .055,
              child: GridPaper(
                color: BmColors.orange,
                divisions: 2,
                interval: 64,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity:
                  CurvedAnimation(parent: _animation, curve: Curves.easeOut),
              child: ScaleTransition(
                scale: Tween<double>(begin: .84, end: 1).animate(
                  CurvedAnimation(
                      parent: _animation, curve: Curves.easeOutBack),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: BmColors.orange.withValues(alpha: .16),
                            blurRadius: 34,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const BmLogo(mark: true, width: 76),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'BM',
                      style: TextStyle(
                        color: BmColors.orange,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Text(
                        t.appTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: BmColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

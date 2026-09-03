import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferenceState {
  const AppPreferenceState({
    this.locale = const Locale('en'),
    this.hasSelectedLanguage = false,
    this.onboardingComplete = false,
    this.isLoaded = false,
  });

  final Locale locale;
  final bool hasSelectedLanguage;
  final bool onboardingComplete;
  final bool isLoaded;

  AppPreferenceState copyWith({
    Locale? locale,
    bool? hasSelectedLanguage,
    bool? onboardingComplete,
    bool? isLoaded,
  }) =>
      AppPreferenceState(
        locale: locale ?? this.locale,
        hasSelectedLanguage: hasSelectedLanguage ?? this.hasSelectedLanguage,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        isLoaded: isLoaded ?? this.isLoaded,
      );
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesController, AppPreferenceState>(
        (ref) => AppPreferencesController());

class AppPreferencesController extends StateNotifier<AppPreferenceState> {
  AppPreferencesController() : super(const AppPreferenceState()) {
    _load();
  }

  static const _languageKey = 'bm_language';
  static const _onboardingKey = 'bm_onboarding_complete';

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final language = preferences.getString(_languageKey);
    state = AppPreferenceState(
      locale: Locale(language ?? 'en'),
      hasSelectedLanguage: language != null,
      onboardingComplete: preferences.getBool(_onboardingKey) ?? false,
      isLoaded: true,
    );
  }

  Future<void> selectLanguage(String languageCode) async {
    state = state.copyWith(
      locale: Locale(languageCode),
      hasSelectedLanguage: true,
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, languageCode);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingComplete: true);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingKey, true);
  }
}

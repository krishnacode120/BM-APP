import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static const supportedLocales = <Locale>[Locale('en'), Locale('ta')];
  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  String get language => locale.languageCode == 'ta' ? 'மொழி' : 'Language';
  String get continueText =>
      locale.languageCode == 'ta' ? 'தொடரவும்' : 'Continue';
  String get getStarted =>
      locale.languageCode == 'ta' ? 'தொடங்குங்கள்' : 'Get started';
  String get phoneLogin => locale.languageCode == 'ta'
      ? 'தொலைபேசியில் தொடரவும்'
      : 'Continue with phone';
  String get enterPhone => locale.languageCode == 'ta'
      ? 'உங்கள் மொபைல் எண்ணை உள்ளிடவும்'
      : 'Enter your mobile number';
  String get verify =>
      locale.languageCode == 'ta' ? 'சரிபார்க்கவும்' : 'Verify';
  String get home => locale.languageCode == 'ta' ? 'முகப்பு' : 'Home';
  String get orders => locale.languageCode == 'ta' ? 'ஆர்டர்கள்' : 'Orders';
  String get cart => locale.languageCode == 'ta' ? 'கூடை' : 'Cart';
  String get profile => locale.languageCode == 'ta' ? 'சுயவிவரம்' : 'Profile';
  String get searchHint => locale.languageCode == 'ta'
      ? 'பொருட்கள், பிராண்டுகள் தேடுங்கள்'
      : 'Search materials, brands, categories...';
  String get shopByCategory =>
      locale.languageCode == 'ta' ? 'வகைப்படி வாங்குங்கள்' : 'Shop by Category';
  String get popularMaterials =>
      locale.languageCode == 'ta' ? 'பிரபலமான பொருட்கள்' : 'Popular Materials';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.contains(Locale(locale.languageCode));
  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

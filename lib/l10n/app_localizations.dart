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
  bool get isTamil => locale.languageCode == 'ta';
  String get selectLocation =>
      isTamil ? 'இடத்தைத் தேர்ந்தெடுக்கவும்' : 'Select location';
  String get currentLocation => isTamil ? 'தற்போதைய இடம்' : 'Current location';
  String get noProducts =>
      isTamil ? 'பொருட்கள் எதுவும் இல்லை' : 'No products found';
  String get noCategories =>
      isTamil ? 'வகைகள் எதுவும் இல்லை' : 'No categories available';
  String get priceOnRequest =>
      isTamil ? 'விலை விசாரிக்கவும்' : 'Price on request';
  String get minimumOrder => isTamil ? 'குறைந்தபட்ச ஆர்டர்' : 'Minimum order';
  String get contactBm => isTamil ? 'BM-ஐ தொடர்பு கொள்ளவும்' : 'Contact BM';
  String get loading => isTamil ? 'ஏற்றுகிறது' : 'Loading';
  String get tryAgain => isTamil ? 'மீண்டும் முயற்சிக்கவும்' : 'Try again';
  String get available => isTamil ? 'கிடைக்கிறது' : 'Available';
  String get lowStock => isTamil ? 'குறைந்த இருப்பு' : 'Low stock';
  String get outOfStock => isTamil ? 'இருப்பு இல்லை' : 'Out of stock';
  String get comingSoon => isTamil ? 'விரைவில் வருகிறது' : 'Coming soon';
  String get deliverTo => isTamil ? 'வழங்க வேண்டிய இடம்' : 'Deliver to';
  String get cartEmpty =>
      isTamil ? 'உங்கள் கூடை காலியாக உள்ளது' : 'Your cart is empty';
  String get browseMaterials =>
      isTamil ? 'பொருட்களைப் பாருங்கள்' : 'Browse Materials';
  String get emptyCartMessage => isTamil
      ? 'கட்டுமானப் பொருட்களைத் தேர்ந்தெடுத்து கூடையில் சேர்க்கவும்.'
      : 'Browse construction materials and add items to your cart.';
  String get subtotal => isTamil ? 'கூட்டுத்தொகை' : 'Subtotal';
  String get estimatedTotal =>
      isTamil ? 'மதிப்பிடப்பட்ட மொத்தம்' : 'Estimated Total';
  String get finalPriceNotice => isTamil
      ? 'இறுதி விலையை BM உறுதிப்படுத்தும்.'
      : 'Final price will be confirmed by BM.';
  String get checkout => isTamil ? 'செக்க்அவுட்' : 'Checkout';
  String get reviewCart =>
      isTamil ? 'கூடையை மதிப்பாய்வு செய்யவும்' : 'Review Cart';
  String get deliveryLocation => isTamil ? 'விநியோக இடம்' : 'Delivery Location';
  String get customerName => isTamil ? 'வாடிக்கையாளர் பெயர்' : 'Customer name';
  String get phoneNumber => isTamil ? 'தொலைபேசி எண்' : 'Phone number';
  String get address => isTamil ? 'முகவரி' : 'Address';
  String get orderNote => isTamil ? 'ஆர்டர் குறிப்பு' : 'Order note';
  String get placeOrder => isTamil ? 'ஆர்டர் செய்யவும்' : 'Place Order';
  String get placingOrder =>
      isTamil ? 'ஆர்டர் செய்யப்படுகிறது' : 'Placing order...';
  String get orderSubmitted =>
      isTamil ? 'ஆர்டர் சமர்ப்பிக்கப்பட்டது' : 'Order Submitted';
  String get viewOrder => isTamil ? 'ஆர்டரைப் பார்க்கவும்' : 'View Order';
  String get continueShopping =>
      isTamil ? 'தொடர்ந்து வாங்குங்கள்' : 'Continue Shopping';
  String get priceUpdated =>
      isTamil ? 'விலை புதுப்பிக்கப்பட்டது' : 'Price updated';
  String get priceUnavailable =>
      isTamil ? 'விலை கிடைக்கவில்லை' : 'Price unavailable';
  String get productUnavailable =>
      isTamil ? 'பொருள் கிடைக்கவில்லை' : 'Product unavailable';
  String get minimumOrderInvalid => isTamil
      ? 'குறைந்தபட்ச ஆர்டர் அளவை பூர்த்தி செய்யவும்.'
      : 'Please update the quantity to meet the minimum order.';
  String get cartPricesChanged =>
      isTamil ? 'கூடை விலைகள் மாறியுள்ளன' : 'Cart prices have changed';
  String get acknowledgePrices =>
      isTamil ? 'விலைகளை ஏற்கிறேன்' : 'Acknowledge prices';
  String get orderHistory => isTamil ? 'ஆர்டர் வரலாறு' : 'Order History';
  String get orderDetails => isTamil ? 'ஆர்டர் விவரங்கள்' : 'Order Details';
  String get paymentPending =>
      isTamil ? 'பணம் நிலுவையில் உள்ளது' : 'Payment Pending';
  String get paymentVerificationRequired =>
      isTamil ? 'பணம் சரிபார்ப்பு தேவை' : 'Payment Verification Required';
  String get paymentNotice => isTamil
      ? 'ஆர்டர் உறுதிப்படுத்தப்பட்ட பிறகு BM நேரடியாக பணம் பற்றிச் சொல்வார்.'
      : 'Payment will be arranged directly with BM after order confirmation.';
  String get somethingWentWrong =>
      isTamil ? 'ஏதோ தவறு ஏற்பட்டது' : 'Something went wrong';
  String get noOrders => isTamil ? 'ஆர்டர்கள் எதுவும் இல்லை' : 'No orders yet';
  String get firebaseUnavailable => isTamil
      ? 'ஆர்டர் செய்ய Firebase development அமைப்பு தேவை.'
      : 'Order submission requires Firebase development configuration.';
  String unitLabel(String unit) => switch (unit) {
        'piece' => isTamil ? 'பீஸ்' : 'Piece',
        'bag' => isTamil ? 'மூட்டை' : 'Bag',
        'load' => isTamil ? 'லோடு' : 'Load',
        'kg' => isTamil ? 'கிலோ' : 'Kg',
        'ton' => isTamil ? 'டன்' : 'Ton',
        'meter' => isTamil ? 'மீட்டர்' : 'Meter',
        'cubicFeet' => isTamil ? 'கன அடி' : 'Cubic Feet',
        _ => isTamil ? 'மற்றவை' : 'Other',
      };
  String orderStatus(String status) => switch (status) {
        'confirmed' => isTamil ? 'உறுதிப்படுத்தப்பட்டது' : 'Confirmed',
        'processing' => isTamil ? 'செயல்பாட்டில்' : 'Processing',
        'ready' => isTamil ? 'தயார்' : 'Ready',
        'outForDelivery' =>
          isTamil ? 'விநியோகத்திற்கு சென்றது' : 'Out for Delivery',
        'delivered' => isTamil ? 'வழங்கப்பட்டது' : 'Delivered',
        'cancelled' => isTamil ? 'ரத்து செய்யப்பட்டது' : 'Cancelled',
        _ => isTamil ? 'நிலுவையில்' : 'Pending',
      };
  String paymentStatus(String status) => switch (status) {
        'verificationRequired' => paymentVerificationRequired,
        'verified' => isTamil ? 'சரிபார்க்கப்பட்டது' : 'Verified',
        'failed' => isTamil ? 'தோல்வியடைந்தது' : 'Failed',
        'refunded' => isTamil ? 'திருப்பிச் செலுத்தப்பட்டது' : 'Refunded',
        'notRequired' => isTamil ? 'தேவை இல்லை' : 'Not Required',
        _ => paymentPending,
      };
  String orderError(String code) => switch (code) {
        'unauthenticated' =>
          isTamil ? 'மீண்டும் உள்நுழைக.' : 'Please sign in again.',
        'price-changed' || 'failed-precondition' => isTamil
            ? 'ஒரு அல்லது பல விலைகள் மாறியுள்ளன. கூடையை மதிப்பாய்வு செய்யவும்.'
            : 'One or more prices changed. Please review your cart.',
        'out-of-stock' => isTamil
            ? 'ஒரு அல்லது பல பொருட்கள் தற்போது கிடைக்கவில்லை.'
            : 'One or more products are currently unavailable.',
        'not-found' => isTamil
            ? 'இந்த இடத்திற்கு விலை கிடைக்கவில்லை.'
            : 'Price is not available for this location.',
        'invalid-argument' => isTamil
            ? 'ஆர்டர் விவரங்களை சரிபார்க்கவும்.'
            : 'Please check the order details.',
        'firebaseUnavailable' => firebaseUnavailable,
        _ => isTamil
            ? 'ஆர்டர் செய்ய முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'
            : "We couldn't place your order. Please try again.",
      };
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

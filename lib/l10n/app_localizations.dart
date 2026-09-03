import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static const supportedLocales = <Locale>[Locale('en'), Locale('ta')];
  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  static AppLocalizations? maybeOf(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

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
  String get appTagline => isTamil
      ? 'கட்டுமானப் பொருட்கள். நேர்மையான விலை. நம்பகமான விநியோகம்.'
      : 'Construction materials. Fair prices. Reliable delivery.';
  String get chooseLanguage =>
      isTamil ? 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்' : 'Choose your language';
  String get languageHelp => isTamil
      ? 'பயன்பாட்டை எந்த மொழியில் பயன்படுத்த விரும்புகிறீர்கள்?'
      : 'Which language would you like to use?';
  String get english => 'English';
  String get tamil => 'தமிழ்';
  String get skip => isTamil ? 'தவிர்க்கவும்' : 'Skip';
  String get next => isTamil ? 'அடுத்து' : 'Next';
  String get welcome => isTamil ? 'மீண்டும் வரவேற்கிறோம்' : 'Welcome back';
  String get welcomeSubtitle => isTamil
      ? 'BM மூலம் உங்கள் கட்டுமானத்தை எளிதாகத் தொடங்குங்கள்.'
      : 'Build easier with trusted materials from BM.';
  String get onboardingFindTitle =>
      isTamil ? 'தேவையான பொருளை கண்டறியுங்கள்' : 'Everything your site needs';
  String get onboardingFindBody => isTamil
      ? 'செங்கல் முதல் ஸ்டீல் வரை தரமான பொருட்களை ஒரே இடத்தில் பாருங்கள்.'
      : 'Browse trusted bricks, cement, sand, steel and more in one place.';
  String get onboardingPriceTitle =>
      isTamil ? 'உங்கள் இடத்திற்கான விலை' : 'Fair local pricing';
  String get onboardingPriceBody => isTamil
      ? 'நீங்கள் தேர்ந்தெடுத்த இடத்திற்கான தற்போதைய விலையை அறியுங்கள்.'
      : 'See the applicable price for your selected delivery location.';
  String get onboardingTrackTitle =>
      isTamil ? 'ஆர்டரை எளிதாகக் கண்காணியுங்கள்' : 'Order with confidence';
  String get onboardingTrackBody => isTamil
      ? 'பாதுகாப்பாக ஆர்டர் செய்து ஒவ்வொரு நிலையையும் கண்காணியுங்கள்.'
      : 'Place secure orders and follow every delivery milestone.';
  String get unableToLoadMaterials => isTamil
      ? 'பொருட்களை இப்போது ஏற்ற முடியவில்லை.'
      : 'Unable to load materials right now.';
  String get locationLoadError =>
      isTamil ? 'இடங்களை ஏற்ற முடியவில்லை' : 'Unable to load locations';
  String get search => isTamil ? 'தேடல்' : 'Search';
  String get categories => isTamil ? 'வகைகள்' : 'Categories';
  String get wishlist => isTamil ? 'விருப்பப் பட்டியல்' : 'Wishlist';
  String get settings => isTamil ? 'அமைப்புகள்' : 'Settings';
  String get addresses => isTamil ? 'சேமித்த முகவரிகள்' : 'Saved Addresses';
  String get support => isTamil ? 'உதவி மற்றும் ஆதரவு' : 'Help & Support';
  String get about => isTamil ? 'BM பற்றி' : 'About BM';
  String get logout => isTamil ? 'வெளியேறு' : 'Log out';
  String get viewAll => isTamil ? 'அனைத்தும்' : 'View all';
  String get todayQuestion => isTamil
      ? 'இன்று உங்கள் கட்டுமானத்திற்கு என்ன தேவை?'
      : 'What do you need for your construction today?';
  String get featuredDeal => isTamil
      ? 'உங்கள் கட்டுமானத்தை வலுப்படுத்துங்கள்'
      : 'Build stronger with BM';
  String get featuredDealBody => isTamil
      ? 'தரமான பொருட்கள், சரியான விலை, நம்பகமான விநியோகம்.'
      : 'Quality materials, local prices and reliable delivery.';
  String get shopNow => isTamil ? 'இப்போது வாங்குங்கள்' : 'Shop now';
  String get allMaterials => isTamil ? 'அனைத்து பொருட்கள்' : 'All Materials';
  String get productDetails => isTamil ? 'பொருள் விவரங்கள்' : 'Product Details';
  String get description => isTamil ? 'விளக்கம்' : 'Description';
  String get specifications => isTamil ? 'விவரக்குறிப்புகள்' : 'Specifications';
  String get quantity => isTamil ? 'அளவு' : 'Quantity';
  String get addToCart => isTamil ? 'கூடையில் சேர்க்கவும்' : 'Add to Cart';
  String get addedToCart =>
      isTamil ? 'கூடையில் சேர்க்கப்பட்டது' : 'Added to cart';
  String get total => isTamil ? 'மொத்தம்' : 'Total';
  String get noWishlist =>
      isTamil ? 'விருப்பப் பட்டியல் காலியாக உள்ளது' : 'Your wishlist is empty';
  String get noWishlistBody => isTamil
      ? 'பின்னர் பார்க்க விரும்பும் பொருட்களை சேமிக்கவும்.'
      : 'Save materials you want to come back to.';
  String get startShopping =>
      isTamil ? 'வாங்கத் தொடங்குங்கள்' : 'Start shopping';
  String get recentSearches =>
      isTamil ? 'சமீபத்திய தேடல்கள்' : 'Recent searches';
  String get clear => isTamil ? 'அழிக்கவும்' : 'Clear';
  String get noSearchResults =>
      isTamil ? 'பொருத்தமான பொருட்கள் இல்லை' : 'No matching materials';
  String get tryAnotherSearch => isTamil
      ? 'வேறு பெயர் அல்லது வகையைத் தேடுங்கள்.'
      : 'Try another material, brand or category.';
  String get account => isTamil ? 'என் கணக்கு' : 'My Account';
  String get orderTracking => isTamil ? 'ஆர்டர் கண்காணிப்பு' : 'Order Tracking';
  String get save => isTamil ? 'சேமிக்கவும்' : 'Save';
  String get addAddress => isTamil ? 'முகவரியைச் சேர்க்கவும்' : 'Add Address';
  String get addressName => isTamil ? 'முகவரி பெயர்' : 'Address name';
  String get addressDetails => isTamil ? 'முழு முகவரி' : 'Full address';
  String get faq => isTamil ? 'அடிக்கடி கேட்கப்படும் கேள்விகள்' : 'FAQs';
  String get supportChat => isTamil ? 'ஆதரவு அரட்டை' : 'Support Chat';
  String get supportChatDemo => isTamil
      ? 'இது ஒரு மாதிரி ஆதரவு அனுபவம். உடனடி உதவிக்கு BM-ஐ அழைக்கவும்.'
      : 'This is a demo support experience. Call BM for immediate help.';
  String get notificationCenter =>
      isTamil ? 'அறிவிப்பு மையம்' : 'Notification Center';
  String get orderConfirmed =>
      isTamil ? 'ஆர்டர் உறுதிப்படுத்தப்பட்டது' : 'Order confirmed';
  String get orderConfirmedBody => isTamil
      ? 'உங்கள் ஆர்டர் பெறப்பட்டது. நிலை மாறும்போது தெரிவிப்போம்.'
      : 'We received your order and will notify you when its status changes.';
  String get admin => isTamil ? 'நிர்வாகம்' : 'Admin';
  String get adminDashboard =>
      isTamil ? 'நிர்வாக டாஷ்போர்டு' : 'Admin Dashboard';
  String get delivery => isTamil ? 'விநியோகம்' : 'Delivery';
  String get approvals => isTamil ? 'ஒப்புதல்கள்' : 'Approvals';
  String get reports => isTamil ? 'அறிக்கைகள்' : 'Reports';
  String get users => isTamil ? 'பயனர்கள்' : 'Users';
  String get products => isTamil ? 'பொருட்கள்' : 'Products';
  String get dashboard => isTamil ? 'டாஷ்போர்டு' : 'Dashboard';
  String get email => isTamil ? 'மின்னஞ்சல்' : 'Email';
  String get password => isTamil ? 'கடவுச்சொல்' : 'Password';
  String get audit => isTamil ? 'தணிக்கை' : 'Audit';
  String get deliveryIntegrationPending => isTamil
      ? 'விநியோக ஒதுக்கீடு அடுத்த பாதுகாப்பான backend இணைப்புக்குத் தயாராக உள்ளது.'
      : 'Delivery assignment is prepared for the next trusted backend integration.';
  String get noPendingApprovals => isTamil
      ? 'தற்போது நிலுவையில் உள்ள ஒப்புதல்கள் இல்லை.'
      : 'There are no pending approvals right now.';
  String get adminDenied => isTamil
      ? 'BM நிர்வாகத்தை அணுக உங்களுக்கு அனுமதி இல்லை.'
      : 'You are not authorized to access BM Admin.';
  String get unableDashboard =>
      isTamil ? 'டாஷ்போர்டை ஏற்ற முடியவில்லை' : 'Unable to load dashboard';
  String get unableOrder =>
      isTamil ? 'ஆர்டரை ஏற்ற முடியவில்லை' : 'Unable to load order';
  String get unableOrders =>
      isTamil ? 'ஆர்டர்களை ஏற்ற முடியவில்லை' : 'Unable to load orders';
  String get unableProducts =>
      isTamil ? 'பொருட்களை ஏற்ற முடியவில்லை' : 'Unable to load products';
  String get unableCategories =>
      isTamil ? 'வகைகளை ஏற்ற முடியவில்லை' : 'Unable to load categories';
  String get unableUsers =>
      isTamil ? 'பயனர்களை ஏற்ற முடியவில்லை' : 'Unable to load users';
  String get unableAudit => isTamil
      ? 'தணிக்கை பதிவுகளை ஏற்ற முடியவில்லை'
      : 'Unable to load audit logs';
  String get unableSync => isTamil
      ? 'ஒத்திசைவு நிலையை ஏற்ற முடியவில்லை'
      : 'Unable to load sync status';
  String get ordersToday => isTamil ? 'இன்றைய ஆர்டர்கள்' : 'Orders Today';
  String get pending => isTamil ? 'நிலுவை' : 'Pending';
  String get processing => isTamil ? 'செயல்பாட்டில்' : 'Processing';
  String get delivered => isTamil ? 'வழங்கப்பட்டது' : 'Delivered';
  String get recentOrders => isTamil ? 'சமீபத்திய ஆர்டர்கள்' : 'Recent Orders';
  String get orderNotFound =>
      isTamil ? 'ஆர்டர் கிடைக்கவில்லை' : 'Order not found';
  String get status => isTamil ? 'நிலை' : 'Status';
  String get payment => isTamil ? 'பணம்' : 'Payment';
  String get location => isTamil ? 'இடம்' : 'Location';
  String get all => isTamil ? 'அனைத்தும்' : 'All';
  String get addProduct => isTamil ? 'பொருளைச் சேர்க்கவும்' : 'Add Product';
  String get trustedCatalogNotice => isTamil
      ? 'பொருள் உருவாக்கம் பாதுகாப்பான நிர்வாக backend மூலம் மட்டுமே செய்யப்படும்.'
      : 'Product creation is available only through the trusted admin backend.';
  String get sortOrder => isTamil ? 'வரிசை' : 'Sort';
  String get auditLogs => isTamil ? 'தணிக்கை பதிவுகள்' : 'Audit Logs';
  String get reportsAndSync =>
      isTamil ? 'அறிக்கைகள் மற்றும் ஒத்திசைவு' : 'Reports & Sync';
  String get csvCopied => isTamil
      ? 'ஆர்டர் CSV நகலெடுக்கப்பட்டது.'
      : 'Orders CSV copied to clipboard.';
  String get csvError => isTamil
      ? 'CSV ஏற்றுமதியை உருவாக்க முடியவில்லை.'
      : 'Unable to create CSV export.';
  String get copyOrdersCsv =>
      isTamil ? 'ஆர்டர் CSV-ஐ நகலெடுக்கவும்' : 'Copy Orders CSV';
  String get totalOrders => isTamil ? 'மொத்த ஆர்டர்கள்' : 'Total Orders';
  String get synced => isTamil ? 'ஒத்திசைக்கப்பட்டது' : 'Synced';
  String get failed => isTamil ? 'தோல்வி' : 'Failed';
  String get reportingSync => isTamil ? 'அறிக்கை ஒத்திசைவு' : 'Reporting sync';
  String get reportingSourceTruth => isTamil
      ? 'Firestore முதன்மை தரவு மூலம். Excel சிறிது தாமதமாக புதுப்பிக்கப்படலாம்.'
      : 'Firestore is the source of truth. Excel may update after a short delay.';
  String get retrySync => isTamil ? 'மீண்டும் ஒத்திசைக்கவும்' : 'Retry sync';
  String get settingsFoundation => isTamil
      ? 'வணிக தொலைபேசி, WhatsApp, ஆதரவு மின்னஞ்சல், நாணயம் மற்றும் பராமரிப்பு முறை அமைப்புகள்.'
      : 'Business settings foundation: business phone, WhatsApp, support email, currency and maintenance mode.';
  String inventoryLabel(String value) => switch (value) {
        'available' => available,
        'lowStock' => lowStock,
        'outOfStock' => outOfStock,
        'comingSoon' => comingSoon,
        _ => isTamil ? 'மறைக்கப்பட்டது' : 'Hidden',
      };
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
  String get help => isTamil ? 'உதவி' : 'Help';
  String get callBm => isTamil ? 'BM-ஐ அழைக்கவும்' : 'Call BM';
  String get whatsappBm =>
      isTamil ? 'WhatsApp-ல் தொடர்பு கொள்ளவும்' : 'WhatsApp BM';
  String get emailBm => isTamil ? 'BM-க்கு மின்னஞ்சல்' : 'Email BM';
  String get supportHours => isTamil ? 'உதவி நேரம்' : 'Support hours';
  String get contactPending => isTamil
      ? 'BM தொடர்பு விவரங்கள் இன்னும் அமைக்கப்படவில்லை.'
      : 'BM contact details have not been configured yet.';
  String get contactUnavailable => isTamil
      ? 'தற்போது தொடர்பு வசதி கிடைக்கவில்லை.'
      : 'Contact options are currently unavailable.';
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
  String get notifications => isTamil ? 'அறிவிப்புகள்' : 'Notifications';
  String get orderUpdates => isTamil ? 'ஆர்டர் அறிவிப்புகள்' : 'Order updates';
  String get notificationRationale => isTamil
      ? 'ஆர்டர் நிலை மற்றும் விநியோக புதுப்பிப்புகளைப் பெற அறிவிப்புகளை இயக்கவும்.'
      : 'Enable notifications to receive order-status and delivery updates.';
  String get enableNotifications =>
      isTamil ? 'அறிவிப்புகளை இயக்கவும்' : 'Enable notifications';
  String get notificationsEnabled =>
      isTamil ? 'அறிவிப்புகள் இயக்கப்பட்டுள்ளன' : 'Notifications are enabled';
  String get notificationsDenied => isTamil
      ? 'அறிவிப்புகள் மறுக்கப்பட்டுள்ளன. சாதன அமைப்புகளில் அவற்றை இயக்கலாம்.'
      : 'Notifications are disabled. You can enable them in device settings.';
  String get notificationsUnavailable => isTamil
      ? 'Firebase அமைக்கப்பட்ட பிறகு அறிவிப்புகள் கிடைக்கும்.'
      : 'Notifications are available after Firebase is configured.';
  String get notificationsNotEnabled => isTamil
      ? 'அறிவிப்புகள் இன்னும் இயக்கப்படவில்லை'
      : 'Notifications are not enabled yet';
  String get firebaseUnavailable => isTamil
      ? 'ஆர்டர் செய்ய Firebase development அமைப்பு தேவை.'
      : 'Order submission requires Firebase development configuration.';
  String get resendOtp =>
      isTamil ? 'குறியீட்டை மீண்டும் அனுப்பவும்' : 'Resend code';
  String get otpInstruction => isTamil
      ? 'உங்கள் மொபைல் எண்ணுக்கு அனுப்பப்பட்ட 6 இலக்க குறியீட்டை உள்ளிடவும்.'
      : 'Enter the 6-digit code sent to your mobile number.';
  String verifyPhone(String phone) =>
      isTamil ? '$phone ஐச் சரிபார்க்கவும்' : 'Verify $phone';
  String authError(String code) => switch (code) {
        'firebaseUnavailable' => isTamil
            ? 'உள்நுழைய Firebase development அமைப்பு தேவை.'
            : 'Phone login requires Firebase development configuration.',
        'invalidPhone' => isTamil
            ? 'சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்.'
            : 'Enter a valid 10-digit mobile number.',
        'invalidOtp' || 'invalid-verification-code' => isTamil
            ? 'தவறான அல்லது காலாவதியான குறியீடு.'
            : 'The code is invalid or expired.',
        'too-many-requests' => isTamil
            ? 'பல முயற்சிகள் செய்யப்பட்டுள்ளன. பிறகு முயற்சிக்கவும்.'
            : 'Too many attempts. Please try again later.',
        _ => isTamil
            ? 'குறியீட்டை அனுப்ப அல்லது சரிபார்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'
            : 'Unable to send or verify the code. Please try again.',
      };
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

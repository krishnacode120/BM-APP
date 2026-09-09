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
  String get createAccount =>
      isTamil ? 'உங்கள் கணக்கை உருவாக்குங்கள்' : 'Create your account';
  String get simpleLoginSubtitle => isTamil
      ? 'உங்கள் பெயர் மற்றும் மொபைல் எண்ணுடன் தொடரவும்.'
      : 'Continue with your name and mobile number.';
  String get signUpSubtitle => isTamil
      ? 'உங்கள் பெயர் மற்றும் மொபைல் எண்ணைச் சரிபார்த்து தொடங்குங்கள்.'
      : 'Verify your name and mobile number to get started.';
  String get fullName => isTamil ? 'முழுப் பெயர்' : 'Full name';
  String get invalidName =>
      isTamil ? 'சரியான பெயரை உள்ளிடவும்.' : 'Enter a valid name.';
  String get sendOtp => isTamil ? 'OTP அனுப்பவும்' : 'Send OTP';
  String get previewCatalog =>
      isTamil ? 'மாதிரி பட்டியலைப் பார்க்கவும்' : 'Preview catalog';
  String get alreadyCustomer => isTamil
      ? 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைக'
      : 'Already a customer? Log in';
  String get newCustomer =>
      isTamil ? 'புதிய வாடிக்கையாளரா? பதிவு செய்க' : 'New customer? Sign up';
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
  String get logoutConfirmation => isTamil
      ? 'இந்த சாதனத்தில் இருந்து வெளியேற வேண்டுமா?'
      : 'Log out from this device?';
  String get cancel => isTamil ? 'ரத்து செய்க' : 'Cancel';
  String get phoneVerified =>
      isTamil ? 'மொபைல் எண் சரிபார்க்கப்பட்டது' : 'Phone verified';
  String get phoneNotVerified =>
      isTamil ? 'மொபைல் எண் சரிபார்க்கப்படவில்லை' : 'Phone not verified';
  String get viewAll => isTamil ? 'அனைத்தும்' : 'View all';
  String get todayQuestion => isTamil
      ? 'இன்று உங்கள் கட்டுமானத்திற்கு என்ன தேவை?'
      : 'What do you need for your construction today?';
  String get goodMorning => isTamil ? 'காலை வணக்கம்' : 'Good Morning';
  String goodMorningName(String name) =>
      isTamil ? 'காலை வணக்கம், $name' : 'Good Morning, $name';
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
  String get addToOrder => isTamil ? 'ஆர்டரில் சேர்க்கவும்' : 'Add to Order';
  String get addedToCart =>
      isTamil ? 'கூடையில் சேர்க்கப்பட்டது' : 'Added to cart';
  String get addedToOrder =>
      isTamil ? 'ஆர்டரில் சேர்க்கப்பட்டது' : 'Added to order';
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
  String get adminLogin => isTamil ? 'நிர்வாக உள்நுழைவு' : 'Admin login';
  String get adminDashboard =>
      isTamil ? 'நிர்வாக டாஷ்போர்டு' : 'Admin Dashboard';
  String get delivery => isTamil ? 'விநியோகம்' : 'Delivery';
  String get approvals => isTamil ? 'ஒப்புதல்கள்' : 'Approvals';
  String get reports => isTamil ? 'அறிக்கைகள்' : 'Reports';
  String get users => isTamil ? 'பயனர்கள்' : 'Users';
  String get customers => isTamil ? 'வாடிக்கையாளர்கள்' : 'Customers';
  String get products => isTamil ? 'பொருட்கள்' : 'Products';
  String get dashboard => isTamil ? 'டாஷ்போர்டு' : 'Dashboard';
  String get refresh => isTamil ? 'புதுப்பிக்கவும்' : 'Refresh';
  String get pendingVerification =>
      isTamil ? 'சரிபார்ப்புக்காக நிலுவை' : 'Pending verification';
  String get verifiedOrders =>
      isTamil ? 'சரிபார்க்கப்பட்ட ஆர்டர்கள்' : 'Verified orders';
  String get availableProducts =>
      isTamil ? 'கிடைக்கும் பொருட்கள்' : 'Available products';
  String get todayRevenue => isTamil ? 'இன்றைய வருவாய்' : "Today's revenue";
  String get paidOrders => isTamil ? 'செலுத்தப்பட்ட ஆர்டர்கள்' : 'Paid orders';
  String get unpaidOrders =>
      isTamil ? 'செலுத்தப்படாத ஆர்டர்கள்' : 'Unpaid orders';
  String get completed => isTamil ? 'நிறைவடைந்தது' : 'Completed';
  String get revenue => isTamil ? 'வருவாய்' : 'Revenue';
  String get orderManagement =>
      isTamil ? 'ஆர்டர் நிர்வாகம்' : 'Order Management';
  String get filterByStatus =>
      isTamil ? 'நிலை மூலம் வடிகட்டவும்' : 'Filter by status';
  String get customerManagement =>
      isTamil ? 'வாடிக்கையாளர் நிர்வாகம்' : 'Customer Management';
  String get searchCustomers => isTamil
      ? 'பெயர் அல்லது மொபைல் எண்ணைத் தேடுங்கள்'
      : 'Search name or mobile number';
  String get noCustomers =>
      isTamil ? 'வாடிக்கையாளர்கள் இல்லை' : 'No customers found';
  String get unnamedCustomer =>
      isTamil ? 'பெயரிடப்படாத வாடிக்கையாளர்' : 'Unnamed customer';
  String get active => isTamil ? 'செயலில்' : 'Active';
  String get inactive => isTamil ? 'செயலில் இல்லை' : 'Inactive';
  String get callCustomer =>
      isTamil ? 'வாடிக்கையாளரை அழைக்கவும்' : 'Call Customer';
  String get verifyOrder =>
      isTamil ? 'ஆர்டரைச் சரிபார்க்கவும்' : 'Verify Order';
  String get productManagement =>
      isTamil ? 'பொருள் நிர்வாகம்' : 'Product Management';
  String get categoryManagement =>
      isTamil ? 'வகை நிர்வாகம்' : 'Category Management';
  String get editProduct => isTamil ? 'பொருளைத் திருத்தவும்' : 'Edit Product';
  String get chooseProductImage =>
      isTamil ? 'பொருள் படத்தைத் தேர்ந்தெடுக்கவும்' : 'Choose product image';
  String get productNameEnglish =>
      isTamil ? 'பொருள் பெயர் (ஆங்கிலம்)' : 'Product name (English)';
  String get productNameTamil =>
      isTamil ? 'பொருள் பெயர் (தமிழ்)' : 'Product name (Tamil)';
  String get category => isTamil ? 'வகை' : 'Category';
  String get descriptionEnglish =>
      isTamil ? 'விளக்கம் (ஆங்கிலம்)' : 'Description (English)';
  String get descriptionTamil =>
      isTamil ? 'விளக்கம் (தமிழ்)' : 'Description (Tamil)';
  String get brand => isTamil ? 'பிராண்ட்' : 'Brand';
  String get unit => isTamil ? 'அலகு' : 'Unit';
  String get invalidQuantity =>
      isTamil ? 'சரியான அளவை உள்ளிடவும்' : 'Enter a valid quantity';
  String get inventoryStatus => isTamil ? 'இருப்பு நிலை' : 'Inventory status';
  String get stockQuantity => isTamil ? 'இருப்பு எண்ணிக்கை' : 'Stock quantity';
  String get searchKeywords =>
      isTamil ? 'தேடல் முக்கிய சொற்கள்' : 'Search keywords';
  String get specificationFormat => isTamil
      ? 'ஒரு வரிக்கு ஒன்று: பெயர்: மதிப்பு'
      : 'One per line: name: value';
  String get popularMaterial =>
      isTamil ? 'பிரபலமான பொருள்' : 'Popular material';
  String get featuredMaterial =>
      isTamil ? 'சிறப்பு பொருள்' : 'Featured material';
  String get locationPricing =>
      isTamil ? 'இடத்திற்கேற்ற விலை' : 'Location pricing';
  String get priceHistoryNotice => isTamil
      ? 'புதிய விலை முந்தைய விலையை மாற்றாமல் புதிய வரலாற்றுப் பதிவை உருவாக்கும்.'
      : 'A new price creates a history record without overwriting the previous price.';
  String get currencySymbol => '₹';
  String get saveProduct => isTamil ? 'பொருளை சேமிக்கவும்' : 'Save Product';
  String get disableProduct =>
      isTamil ? 'பொருளை முடக்கவும்' : 'Disable product';
  String get enableProduct => isTamil ? 'பொருளை இயக்கவும்' : 'Enable product';
  String get disableProductMessage => isTamil
      ? 'இந்த பொருள் வாடிக்கையாளர்களுக்கு மறைக்கப்படும். தொடர வேண்டுமா?'
      : 'This product will be hidden from customers. Continue?';
  String get enableProductMessage => isTamil
      ? 'இந்த பொருள் வாடிக்கையாளர்களுக்குத் தெரியும். தொடர வேண்டுமா?'
      : 'This product will become visible to customers. Continue?';
  String get requiredField =>
      isTamil ? 'இந்த புலம் அவசியம்' : 'This field is required';
  String get addCategory => isTamil ? 'வகையைச் சேர்க்கவும்' : 'Add Category';
  String get editCategory => isTamil ? 'வகையைத் திருத்தவும்' : 'Edit Category';
  String get disableCategory =>
      isTamil ? 'வகையை முடக்கவும்' : 'Disable category';
  String get enableCategory => isTamil ? 'வகையை இயக்கவும்' : 'Enable category';
  String get disableCategoryMessage => isTamil
      ? 'இந்த வகை வாடிக்கையாளர்களுக்கு மறைக்கப்படும். தொடர வேண்டுமா?'
      : 'This category will be hidden from customers. Continue?';
  String get enableCategoryMessage => isTamil
      ? 'இந்த வகை வாடிக்கையாளர்களுக்குத் தெரியும். தொடர வேண்டுமா?'
      : 'This category will become visible to customers. Continue?';
  String get categoryNameEnglish =>
      isTamil ? 'வகை பெயர் (ஆங்கிலம்)' : 'Category name (English)';
  String get categoryNameTamil =>
      isTamil ? 'வகை பெயர் (தமிழ்)' : 'Category name (Tamil)';
  String get imageUrl => isTamil ? 'பட URL' : 'Image URL';
  String get recognizedRevenue =>
      isTamil ? 'அங்கீகரிக்கப்பட்ட வருவாய்' : 'Recognized revenue';
  String get syncNeedsAttention =>
      isTamil ? 'கவனம் தேவைப்படும் ஒத்திசைவு' : 'Sync needs attention';
  String get revenueLastSevenDays =>
      isTamil ? 'கடந்த 7 நாட்களின் வருவாய்' : 'Revenue — last 7 days';
  String get dateRange => isTamil ? 'தேதி வரம்பு' : 'Date range';
  String get today => isTamil ? 'இன்று' : 'Today';
  String get sevenDays => isTamil ? '7 நாட்கள்' : '7 Days';
  String get thirtyDays => isTamil ? '30 நாட்கள்' : '30 Days';
  String get customRange => isTamil ? 'தனிப்பயன்' : 'Custom';
  String get cancelledOrders =>
      isTamil ? 'ரத்து செய்யப்பட்ட ஆர்டர்கள்' : 'Cancelled orders';
  String get paidTotal => isTamil ? 'செலுத்தப்பட்ட மொத்தம்' : 'Paid total';
  String get unpaidTotal => isTamil ? 'செலுத்தப்படாத மொத்தம்' : 'Unpaid total';
  String get monthlyRevenue => isTamil ? 'மாத வருவாய்' : 'Monthly revenue';
  String get revenueChart => isTamil ? 'வருவாய் வரைபடம்' : 'Revenue chart';
  String get orderCount => isTamil ? 'ஆர்டர் எண்ணிக்கை' : 'Order count';
  String get topMaterials =>
      isTamil ? 'அதிகம் ஆர்டர் செய்யப்பட்ட பொருட்கள்' : 'Top materials';
  String get noReportData =>
      isTamil ? 'அறிக்கை தரவு இல்லை' : 'No report data yet';
  String get attempts => isTamil ? 'முயற்சிகள்' : 'attempts';
  String get lastSync => isTamil ? 'கடைசி ஒத்திசைவு' : 'Last sync';
  String get adminSettings => isTamil ? 'நிர்வாக அமைப்புகள்' : 'Admin Settings';
  String get unableSettings =>
      isTamil ? 'அமைப்புகளை ஏற்ற முடியவில்லை' : 'Unable to load settings';
  String get businessName => isTamil ? 'வணிக பெயர்' : 'Business name';
  String get businessPhone => isTamil ? 'வணிக தொலைபேசி' : 'Business phone';
  String get whatsappNumber => isTamil ? 'WhatsApp எண்' : 'WhatsApp number';
  String get supportEmail => isTamil ? 'ஆதரவு மின்னஞ்சல்' : 'Support email';
  String get currency => isTamil ? 'நாணயம்' : 'Currency';
  String get saveSettings =>
      isTamil ? 'அமைப்புகளை சேமிக்கவும்' : 'Save Settings';
  String get invalidSettings => isTamil
      ? 'சரியான தொலைபேசி, WhatsApp மற்றும் மின்னஞ்சல் விவரங்களை உள்ளிடவும்.'
      : 'Enter valid phone, WhatsApp and email details.';
  String get settingsSaved =>
      isTamil ? 'அமைப்புகள் சேமிக்கப்பட்டன' : 'Settings saved';
  String get confirmSettingsChange => isTamil
      ? 'புதிய தொடர்பு விவரங்களை வாடிக்கையாளர்களுக்குப் பயன்படுத்த வேண்டுமா?'
      : 'Use these new contact details for customer actions?';
  String get changePassword =>
      isTamil ? 'கடவுச்சொல்லை மாற்றவும்' : 'Change password';
  String get currentPassword =>
      isTamil ? 'தற்போதைய கடவுச்சொல்' : 'Current password';
  String get newPassword => isTamil ? 'புதிய கடவுச்சொல்' : 'New password';
  String get confirmNewPassword =>
      isTamil ? 'புதிய கடவுச்சொல்லை உறுதிசெய்க' : 'Confirm new password';
  String get update => isTamil ? 'புதுப்பிக்கவும்' : 'Update';
  String get passwordUpdated =>
      isTamil ? 'கடவுச்சொல் புதுப்பிக்கப்பட்டது' : 'Password updated';
  String get updateOrderStatus =>
      isTamil ? 'ஆர்டர் நிலையை மாற்றவும்' : 'Update order status';
  String get updatePaymentStatus =>
      isTamil ? 'பண நிலையை மாற்றவும்' : 'Update payment status';
  String confirmStatusChange(String value) => isTamil
      ? 'ஆர்டர் நிலையை “$value” என மாற்ற வேண்டுமா?'
      : 'Change the order status to “$value”?';
  String confirmPaymentChange(String value) => isTamil
      ? 'பண நிலையை “$value” என மாற்ற வேண்டுமா?'
      : 'Change the payment status to “$value”?';
  String get confirm => isTamil ? 'உறுதிசெய்க' : 'Confirm';
  String get confirmFinalAmount =>
      isTamil ? 'இறுதி தொகையை உறுதிசெய்க' : 'Confirm final amount';
  String get confirmedSubtotal =>
      isTamil ? 'உறுதியான கூட்டுத்தொகை' : 'Confirmed subtotal';
  String get deliveryCharge => isTamil ? 'விநியோக கட்டணம்' : 'Delivery charge';
  String get adminNote => isTamil ? 'நிர்வாக குறிப்பு' : 'Admin note';
  String get paymentStatusLabel =>
      isTamil ? 'பணம் செலுத்தும் நிலை' : 'Payment status';
  String adminError(String code) => switch (code) {
        'migrationPending' => migrationFoundation,
        'invalid-image' => isTamil
            ? '5 MB-க்கு குறைவான சரியான படத்தைத் தேர்ந்தெடுக்கவும்.'
            : 'Choose a valid image smaller than 5 MB.',
        'wrong-password' || 'invalid-credential' => isTamil
            ? 'தற்போதைய கடவுச்சொல் தவறானது.'
            : 'The current password is incorrect.',
        'failed-precondition' => isTamil
            ? 'இந்த மாற்றம் தற்போதைய நிலையில் அனுமதிக்கப்படவில்லை.'
            : 'This change is not allowed from the current state.',
        _ => isTamil
            ? 'செயலை முடிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'
            : 'Unable to complete the action. Please try again.',
      };
  String get email => isTamil ? 'மின்னஞ்சல்' : 'Email';
  String get unableAdminAccess => isTamil
      ? 'நிர்வாக அணுகலைச் சரிபார்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'
      : 'Unable to check admin access. Please try again.';
  String adminLoginError(String code) => switch (code) {
        'migrationPending' => migrationFoundation,
        'firebaseUnavailable' => firebaseUnavailable,
        'invalid-email' => isTamil
            ? 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்.'
            : 'Enter a valid email address.',
        'missing-password' =>
          isTamil ? 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்.' : 'Enter your password.',
        'wrong-password' || 'invalid-credential' || 'user-not-found' => isTamil
            ? 'மின்னஞ்சல் அல்லது கடவுச்சொல் தவறானது.'
            : 'The email or password is incorrect.',
        'user-disabled' => isTamil
            ? 'இந்தக் கணக்கு முடக்கப்பட்டுள்ளது. BM-ஐத் தொடர்புகொள்ளவும்.'
            : 'This account is disabled. Contact BM.',
        'network-request-failed' => isTamil
            ? 'இணைய இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.'
            : 'Check your internet connection and try again.',
        'too-many-requests' => authError(code),
        _ => isTamil
            ? 'உள்நுழைய முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'
            : 'Unable to sign in. Please try again.',
      };
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
  String get exportCsv => isTamil ? 'CSV ஏற்றுமதி' : 'Export CSV';
  String get ordersReport => isTamil ? 'ஆர்டர் CSV' : 'Orders CSV';
  String get revenueReport => isTamil ? 'வருவாய் CSV' : 'Revenue CSV';
  String get productsReport => isTamil ? 'பொருட்கள் CSV' : 'Products CSV';
  String get customersReport =>
      isTamil ? 'வாடிக்கையாளர்கள் CSV' : 'Customers CSV';
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
  String get callAdmin => isTamil ? 'நிர்வாகியை அழைக்கவும்' : 'Call Admin';
  String get call => isTamil ? 'அழைக்கவும்' : 'Call';
  String get howCanWeHelp =>
      isTamil ? 'நாங்கள் எப்படி உதவலாம்?' : 'How can we help?';
  String get callAdminHelp => isTamil
      ? 'ஆர்டர் அல்லது பொருள் உதவிக்கு BM நிர்வாகியை நேரடியாக அழைக்கவும்.'
      : 'Call the BM administrator directly for order or material help.';
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
  String get estimatedOrderValue =>
      isTamil ? 'மதிப்பிடப்பட்ட ஆர்டர் மதிப்பு' : 'Estimated Order Value';
  String get finalPriceNotice => isTamil
      ? 'இறுதி விலையை BM உறுதிப்படுத்தும்.'
      : 'Final price will be confirmed by BM.';
  String get checkout => isTamil ? 'செக்க்அவுட்' : 'Checkout';
  String get submitOrder => isTamil ? 'ஆர்டரை சமர்ப்பிக்கவும்' : 'Submit Order';
  String get customerDetails =>
      isTamil ? 'வாடிக்கையாளர் விவரங்கள்' : 'Customer Details';
  String get orderSummary => isTamil ? 'ஆர்டர் சுருக்கம்' : 'Order Summary';
  String get signInRequired =>
      isTamil ? 'முதலில் உள்நுழையவும்' : 'Sign in required';
  String get confirmOrder =>
      isTamil ? 'ஆர்டரை உறுதிசெய்யவும்' : 'Confirm Order';
  String get confirmOrderMessage =>
      isTamil ? 'இந்த ஆர்டரை செய்ய வேண்டுமா?' : 'Place this order?';
  String get reviewCart =>
      isTamil ? 'கூடையை மதிப்பாய்வு செய்யவும்' : 'Review Cart';
  String get reviewOrder =>
      isTamil ? 'ஆர்டர் பட்டியலை மதிப்பாய்வு செய்யவும்' : 'Review your order';
  String get continueToSubmit =>
      isTamil ? 'சமர்ப்பிக்கத் தொடரவும்' : 'Continue to Submit';
  String get orderListEmpty => isTamil
      ? 'உங்கள் ஆர்டர் பட்டியல் காலியாக உள்ளது'
      : 'Your order list is empty';
  String get emptyOrderMessage => isTamil
      ? 'கட்டுமானப் பொருட்களைத் தேர்ந்தெடுத்து ஆர்டரில் சேர்க்கவும்.'
      : 'Browse construction materials and add them to your order.';
  String get deliveryLocation => isTamil ? 'விநியோக இடம்' : 'Delivery Location';
  String get customerName => isTamil ? 'வாடிக்கையாளர் பெயர்' : 'Customer name';
  String get phoneNumber => isTamil ? 'தொலைபேசி எண்' : 'Phone number';
  String get address => isTamil ? 'முகவரி' : 'Address';
  String get orderNote => isTamil ? 'ஆர்டர் குறிப்பு' : 'Order note';
  String get placeOrder => isTamil ? 'ஆர்டர் செய்யவும்' : 'Place Order';
  String get placingOrder =>
      isTamil ? 'ஆர்டர் செய்யப்படுகிறது' : 'Placing order...';
  String get orderSubmitted => isTamil
      ? 'ஆர்டர் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது'
      : 'Order Submitted Successfully';
  String get orderSuccessMessage => isTamil
      ? 'உங்கள் ஆர்டர் BM-க்கு அனுப்பப்பட்டது. BM விரைவில் உங்களைத் தொடர்பு கொள்ளும்.'
      : 'Your order has been sent to BM. BM will contact you shortly.';
  String get finalTotal => isTamil ? 'இறுதி மொத்தம்' : 'Final Total';
  String get orderDate => isTamil ? 'ஆர்டர் தேதி' : 'Order date';
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
      ? 'இந்தப் பதிப்பில் அறிவிப்புச் சேவை இன்னும் தயாராகவில்லை.'
      : 'The notification service is not ready in this build.';
  String get notificationsNotEnabled => isTamil
      ? 'அறிவிப்புகள் இன்னும் இயக்கப்படவில்லை'
      : 'Notifications are not enabled yet';
  String get firebaseUnavailable => isTamil
      ? 'இந்தப் பதிப்பில் சேவையுடன் இணைக்க முடியவில்லை. BM-ஐத் தொடர்புகொள்ளவும்.'
      : 'This app version cannot connect to the service. Please contact BM.';
  String get migrationFoundation => isTamil
      ? 'இது சோதனைப் பதிப்பு. ஆர்டர் மற்றும் நிர்வாக வசதிகள் இன்னும் மாற்றப்படவில்லை.'
      : 'Development foundation: ordering and admin operations are not migrated yet.';
  String get resendOtp =>
      isTamil ? 'குறியீட்டை மீண்டும் அனுப்பவும்' : 'Resend code';
  String resendOtpIn(int seconds) => isTamil
      ? '$seconds வினாடிகளில் மீண்டும் அனுப்பலாம்'
      : 'Resend in ${seconds}s';
  String get otpCode =>
      isTamil ? 'ஒருமுறை கடவுக்குறியீடு' : 'Verification code';
  String get otpInstruction => isTamil
      ? 'உங்கள் மொபைல் எண்ணுக்கு அனுப்பப்பட்ட 6 இலக்க குறியீட்டை உள்ளிடவும்.'
      : 'Enter the 6-digit code sent to your mobile number.';
  String verifyPhone(String phone) =>
      isTamil ? '$phone ஐச் சரிபார்க்கவும்' : 'Verify $phone';
  String authError(String code) => switch (code) {
        'firebaseUnavailable' => firebaseUnavailable,
        'invalidPhone' || 'invalid-phone-number' => isTamil
            ? 'சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்.'
            : 'Enter a valid 10-digit mobile number.',
        'invalidOtp' ||
        'invalid-verification-code' ||
        'session-expired' ||
        'invalid-verification-id' =>
          isTamil
              ? 'தவறான அல்லது காலாவதியான குறியீடு.'
              : 'The code is invalid or expired.',
        'too-many-requests' => isTamil
            ? 'பல முயற்சிகள் செய்யப்பட்டுள்ளன. பிறகு முயற்சிக்கவும்.'
            : 'Too many attempts. Please try again later.',
        'otpRequestTimeout' => isTamil
            ? 'சரிபார்ப்பு பதில் வரவில்லை. மீண்டும் முயற்சிக்கவும்.'
            : 'No verification response was received. Please try again.',
        'customerProfileFailed' => isTamil
            ? 'மொபைல் எண் சரிபார்க்கப்பட்டது. விவரங்களைச் சேமிக்க மீண்டும் முயற்சிக்கவும்.'
            : 'Your phone was verified, but your profile could not be saved. Please try again.',
        'customerInactive' || 'user-disabled' => isTamil
            ? 'இந்தக் கணக்கு செயல்பாட்டில் இல்லை. BM-ஐத் தொடர்புகொள்ளவும்.'
            : 'This account is inactive. Contact BM.',
        'customerRoleMismatch' => isTamil
            ? 'இந்தக் கணக்கிற்கு நிர்வாக உள்நுழைவைப் பயன்படுத்தவும்.'
            : 'Use admin login for this account.',
        'phoneMismatch' => isTamil
            ? 'மொபைல் சரிபார்ப்பு இந்தக் கணக்குடன் பொருந்தவில்லை. மீண்டும் உள்நுழையவும்.'
            : 'Phone verification does not match this account. Please sign in again.',
        'network-request-failed' => adminLoginError(code),
        'billing-not-enabled' ||
        'quota-exceeded' ||
        'operation-not-allowed' =>
          isTamil
              ? 'SMS உள்நுழைவு தற்போது கிடைக்கவில்லை. BM-ஐத் தொடர்புகொள்ளவும்.'
              : 'SMS sign-in is currently unavailable. Please contact BM.',
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
        'verified' => isTamil ? 'சரிபார்க்கப்பட்டது' : 'Verified',
        'confirmed' => isTamil ? 'உறுதிப்படுத்தப்பட்டது' : 'Confirmed',
        'processing' => isTamil ? 'செயல்பாட்டில்' : 'Processing',
        'ready' => isTamil ? 'தயார்' : 'Ready',
        'completed' => isTamil ? 'நிறைவடைந்தது' : 'Completed',
        'cancelled' => isTamil ? 'ரத்து செய்யப்பட்டது' : 'Cancelled',
        _ => isTamil ? 'நிலுவையில்' : 'Pending',
      };
  String paymentStatus(String status) => switch (status) {
        'partial' => isTamil ? 'பகுதி செலுத்தப்பட்டது' : 'Partially paid',
        'paid' => isTamil ? 'செலுத்தப்பட்டது' : 'Paid',
        _ => isTamil ? 'செலுத்தப்படவில்லை' : 'Unpaid',
      };
  String orderError(String code) => switch (code) {
        'migrationPending' => migrationFoundation,
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

import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessSettings {
  const BusinessSettings({
    required this.businessName,
    required this.businessPhone,
    required this.whatsappNumber,
    required this.supportEmail,
    required this.defaultCurrency,
    required this.supportHours,
    required this.isDevelopmentFallback,
  });

  final String businessName;
  final String businessPhone;
  final String whatsappNumber;
  final String supportEmail;
  final String defaultCurrency;
  final String supportHours;
  final bool isDevelopmentFallback;

  bool get canCall => RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(businessPhone);
  bool get canWhatsapp => RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(whatsappNumber);
  bool get hasSupportEmail => supportEmail.contains('@');

  Map<String, Object?> toJson() => <String, Object?>{
        'businessName': businessName.trim(),
        'businessPhone': businessPhone.trim(),
        'whatsappNumber': whatsappNumber.trim(),
        'supportEmail': supportEmail.trim(),
        'defaultCurrency': defaultCurrency.trim(),
        'supportHours': supportHours.trim(),
      };

  factory BusinessSettings.fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> document) =>
      BusinessSettings(
        businessName: document.data()?['businessName'] as String? ?? 'BM',
        businessPhone:
            document.data()?['businessPhone'] as String? ?? '+91XXXXXXXXXX',
        whatsappNumber:
            document.data()?['whatsappNumber'] as String? ?? '+91XXXXXXXXXX',
        supportEmail: document.data()?['supportEmail'] as String? ?? '',
        defaultCurrency:
            document.data()?['defaultCurrency'] as String? ?? 'INR',
        supportHours: document.data()?['supportHours'] as String? ?? '',
        isDevelopmentFallback: false,
      );

  static const developmentFallback = BusinessSettings(
    businessName: 'BM',
    businessPhone: '+91XXXXXXXXXX',
    whatsappNumber: '+91XXXXXXXXXX',
    supportEmail: '',
    defaultCurrency: 'INR',
    supportHours: '',
    isDevelopmentFallback: true,
  );
}

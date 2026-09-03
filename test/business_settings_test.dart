import 'package:bm/models/business_settings.dart';
import 'package:bm/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('development contact placeholders cannot trigger call actions', () {
    expect(BusinessSettings.developmentFallback.canCall, isFalse);
    expect(BusinessSettings.developmentFallback.canWhatsapp, isFalse);
  });

  test('unavailable auth never returns a fake OTP credential', () async {
    final service = UnavailableAuthService();
    await expectLater(
        service.verifyOtp(verificationId: 'test', smsCode: '123456'),
        throwsA(isA<AuthFailure>()));
  });
}

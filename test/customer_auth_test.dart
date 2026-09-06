import 'package:bm/repositories/customer_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('customer identity validation', () {
    test('normalizes supported Indian mobile formats', () {
      expect(normalizeIndianPhone('98765 43210'), '+919876543210');
      expect(normalizeIndianPhone('+91-98765-43210'), '+919876543210');
    });

    test('rejects invalid mobile numbers', () {
      expect(normalizeIndianPhone('12345'), isNull);
      expect(normalizeIndianPhone('5876543210'), isNull);
      expect(normalizeIndianPhone('abc9876543210'), isNull);
      expect(normalizeIndianPhone('98765+43210'), isNull);
    });

    test('accepts English and Tamil customer names', () {
      expect(validateCustomerName('Krishna Kumar'), isNull);
      expect(validateCustomerName('கிருஷ்ணா'), isNull);
      expect(validateCustomerName('1'), 'invalidName');
    });
  });
  test('OTP cannot demote an admin or reactivate a disabled customer', () {
    final data = <String, dynamic>{
      'role': 'customer',
      'isActive': true,
      'phoneVerified': true,
      'phoneNumber': '+919876543210'
    };
    expect(
        () => validateExistingCustomer(data, '+919876543210'), returnsNormally);
    expect(
        () => validateExistingCustomer(
            {...data, 'role': 'admin'}, '+919876543210'),
        throwsA(isA<CustomerFailure>()
            .having((e) => e.code, 'code', 'customerRoleMismatch')));
    expect(
        () => validateExistingCustomer(
            {...data, 'isActive': false}, '+919876543210'),
        throwsA(isA<CustomerFailure>()
            .having((e) => e.code, 'code', 'customerInactive')));
    expect(
        () => validateExistingCustomer(data, '+919876543211'),
        throwsA(isA<CustomerFailure>()
            .having((e) => e.code, 'code', 'phoneMismatch')));
  });
}

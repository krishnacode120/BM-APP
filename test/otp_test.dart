import 'dart:async';

import 'package:bm/features/auth/auth_providers.dart';
import 'package:bm/features/auth/otp_controller.dart';
import 'package:bm/features/auth/otp_page.dart';
import 'package:bm/l10n/app_localizations.dart';
import 'package:bm/models/customer_profile.dart';
import 'package:bm/models/auth_identity.dart';
import 'package:bm/repositories/customer_repository.dart';
import 'package:bm/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const arguments = OtpArguments(
    phone: '+919876543210', fullName: 'Test Customer', createAccount: false);

class TestUser extends Fake implements User {
  @override
  String get uid => 'customer-test';
  @override
  String get phoneNumber => arguments.phone;
}

class TestCredential extends Fake implements UserCredential {
  TestCredential(this.user);
  @override
  final User? user;
}

class TestCustomers extends Fake implements CustomerRepository {
  int saves = 0;
  Object? failure;
  @override
  Future<CustomerProfile> saveVerifiedCustomer(
      {required AuthIdentity user,
      required String name,
      required String phoneNumber}) async {
    saves++;
    if (failure != null) throw failure!;
    return CustomerProfile(
        uid: user.uid,
        name: name,
        phoneNumber: phoneNumber,
        phoneVerified: true,
        isActive: true,
        createdAt: null,
        updatedAt: null);
  }
}

class TestAuth extends Fake implements AuthService {
  final requests = <StreamController<PhoneVerificationEvent>>[];
  bool? resent;
  int verifications = 0;
  AuthSessionResult credential = const AuthSessionResult(
      AuthIdentity(uid: 'customer-test', phoneNumber: '+919876543210'));
  Object? failure;
  @override
  Stream<PhoneVerificationEvent> requestOtp(
      {required String phoneNumber, bool forceResend = false}) {
    resent = forceResend;
    final request = StreamController<PhoneVerificationEvent>();
    requests.add(request);
    return request.stream;
  }

  @override
  Future<AuthSessionResult> verifyOtp(
      {required String verificationId, required String smsCode}) async {
    verifications++;
    if (failure != null) throw failure!;
    return credential;
  }
}

class NativeAuth extends Fake implements FirebaseAuth {
  final calls = <Map<Symbol, dynamic>>[];
  Object? requestError;
  int signs = 0;
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #verifyPhoneNumber) {
      calls.add(invocation.namedArguments);
      return requestError == null
          ? Future<void>.value()
          : Future<void>.error(requestError!);
    }
    if (invocation.memberName == #signInWithCredential) {
      signs++;
      return Future<UserCredential>.value(TestCredential(TestUser()));
    }
    return super.noSuchMethod(invocation);
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('OTP controller', () {
    late TestAuth auth;
    late TestCustomers customers;
    late OtpController controller;
    setUp(() {
      auth = TestAuth();
      customers = TestCustomers();
      controller = OtpController(auth, customers, arguments);
    });
    tearDown(() => controller.dispose());

    test('request failure releases loading and exposes a safe code', () async {
      await controller.request();
      expect(controller.state.requesting, isTrue);
      auth.requests.last.addError(const AuthFailure('billing-not-enabled'));
      await flush();
      expect(controller.state.busy, isFalse);
      expect(controller.state.errorCode, 'billing-not-enabled');
    });

    test('manual verification saves a profile before reporting success',
        () async {
      await controller.request();
      auth.requests.last.add(const PhoneCodeSentEvent('id'));
      await flush();
      await controller.verify('123456');
      expect(customers.saves, 1);
      expect(controller.state.completed, isTrue);
    });

    test('automatic verification also saves the profile', () async {
      await controller.request();
      auth.requests.last.add(PhoneVerified(auth.credential));
      await flush();
      expect(customers.saves, 1);
      expect(controller.state.completed, isTrue);
    });

    test('null user never reports success', () async {
      await controller.request();
      auth.requests.last.add(const PhoneVerified(AuthSessionResult(null)));
      await flush();
      expect(customers.saves, 0);
      expect(controller.state.completed, isFalse);
      expect(controller.state.errorCode, 'invalidOtp');
    });

    test('profile save failures never navigate to home', () async {
      customers.failure = Exception('private backend details');
      await controller.request();
      auth.requests.last.add(PhoneVerified(auth.credential));
      await flush();
      expect(controller.state.completed, isFalse);
      expect(controller.state.errorCode, 'customerProfileFailed');
    });

    test('resend replaces verification ID and cancels old callbacks', () async {
      await controller.request();
      final old = auth.requests.last;
      old.add(const PhoneCodeSentEvent('old'));
      await flush();
      await controller.request(resend: true);
      expect(auth.resent, isTrue);
      expect(old.hasListener, isFalse);
      expect(controller.state.verificationId, isNull);
      auth.requests.last.add(const PhoneCodeSentEvent('new'));
      await flush();
      expect(controller.state.verificationId, 'new');
    });

    test('rejects non-numeric codes and supports retry after invalid OTP',
        () async {
      await controller.request();
      auth.requests.last.add(const PhoneCodeSentEvent('id'));
      await flush();
      await controller.verify('abcdef');
      expect(auth.verifications, 0);
      auth.failure = const AuthFailure('invalid-verification-code');
      await controller.verify('123456');
      expect(controller.state.busy, isFalse);
      expect(controller.state.verificationId, 'id');
      auth.failure = null;
      await controller.verify('123456');
      expect(controller.state.completed, isTrue);
    });

    test('empty callback stream does not leave spinner running', () async {
      await controller.request();
      await auth.requests.last.close();
      expect(controller.state.errorCode, 'otpRequestTimeout');
    });
  });

  group('native phone service', () {
    test('catches direct native request errors', () async {
      final native = NativeAuth()
        ..requestError = FirebaseAuthException(code: 'operation-not-allowed');
      await expectLater(
          FirebasePhoneAuthService(native)
              .requestOtp(phoneNumber: arguments.phone),
          emitsError(isA<AuthFailure>()
              .having((e) => e.code, 'code', 'operation-not-allowed')));
    });

    test('times out a request without callbacks', () async {
      await expectLater(
          FirebasePhoneAuthService(NativeAuth(),
                  requestTimeout: const Duration(milliseconds: 10))
              .requestOtp(phoneNumber: arguments.phone),
          emitsError(isA<AuthFailure>()
              .having((e) => e.code, 'code', 'otpRequestTimeout')));
    });

    test('resend tokens are scoped to the same phone; iOS null is accepted',
        () async {
      final native = NativeAuth();
      final service = FirebasePhoneAuthService(native);
      var sub = service.requestOtp(phoneNumber: arguments.phone).listen((_) {});
      await flush();
      native.calls.last[#codeSent]('first', 7);
      await sub.cancel();
      sub = service
          .requestOtp(phoneNumber: arguments.phone, forceResend: true)
          .listen((_) {});
      await flush();
      expect(native.calls.last[#forceResendingToken], 7);
      native.calls.last[#codeSent]('second', null);
      await sub.cancel();
      sub = service
          .requestOtp(phoneNumber: arguments.phone, forceResend: true)
          .listen((_) {});
      await flush();
      expect(native.calls.last[#forceResendingToken], isNull);
      native.calls.last[#codeSent]('third', 8);
      await sub.cancel();
      sub = service
          .requestOtp(phoneNumber: '+919876543211', forceResend: true)
          .listen((_) {});
      await flush();
      expect(native.calls.last[#forceResendingToken], isNull);
      await sub.cancel();
    });

    test('automatic credential signs in and emits a verified event', () async {
      final native = NativeAuth();
      final events = <PhoneVerificationEvent>[];
      final sub = FirebasePhoneAuthService(native)
          .requestOtp(phoneNumber: arguments.phone)
          .listen(events.add);
      await flush();
      await native.calls.last[#verificationCompleted](
          PhoneAuthProvider.credential(
              verificationId: 'id', smsCode: '123456'));
      await flush();
      expect(native.signs, 1);
      expect(events.single, isA<PhoneVerified>());
      await sub.cancel();
    });

    test('cancelled request ignores later automatic callback', () async {
      final native = NativeAuth();
      final sub = FirebasePhoneAuthService(native)
          .requestOtp(phoneNumber: arguments.phone)
          .listen((_) {});
      await flush();
      await sub.cancel();
      await native.calls.last[#verificationCompleted](
          PhoneAuthProvider.credential(
              verificationId: 'id', smsCode: '123456'));
      expect(native.signs, 0);
    });
  });

  testWidgets('OTP fits a small iPhone with keyboard and Tamil error text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final auth = TestAuth();
    await tester.pumpWidget(ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(auth),
          customerRepositoryProvider.overrideWithValue(TestCustomers()),
        ],
        child: MaterialApp(
            locale: const Locale('ta'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            home: const OtpPage(arguments: arguments))));
    await tester.pump();
    auth.requests.last.addError(const AuthFailure('billing-not-enabled'));
    await tester.pump();
    expect(
        find.text(AppLocalizations(const Locale('ta'))
            .authError('billing-not-enabled')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

import 'dart:convert';
import 'package:bm/core/config/backend_config.dart';
import 'package:bm/features/admin/admin_providers.dart';
import 'package:bm/features/auth/auth_providers.dart';
import 'package:bm/features/catalog/catalog_providers.dart';
import 'package:bm/features/notifications/notification_providers.dart';
import 'package:bm/features/orders/order_providers.dart';
import 'package:bm/l10n/app_localizations.dart';
import 'package:bm/models/auth_identity.dart';
import 'package:bm/repositories/admin_repository.dart';
import 'package:bm/repositories/order_repository.dart';
import 'package:bm/repositories/supabase_catalog_repository.dart';
import 'package:bm/repositories/supabase_customer_repository.dart';
import 'package:bm/services/auth_service.dart';
import 'package:bm/services/supabase_auth_service.dart';
import 'package:bm/services/notification_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

const uid = '00000000-0000-0000-0000-000000000001';
const phone = '+919000000001';
const config = BackendConfig(
    backend: BackendKind.supabase,
    url: 'https://example.supabase.co',
    publishableKey: 'sb_publishable_fixture');
const user = <String, dynamic>{
  'id': uid,
  'phone': '919000000001',
  'phone_confirmed_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'aud': 'authenticated',
  'app_metadata': <String, dynamic>{},
  'user_metadata': {'role': 'super_admin'},
};
final productRow = <String, dynamic>{
  'id': 'brick',
  'category_id': 'bricks',
  'name': 'Red Brick',
  'name_tamil': 'செங்கல்',
  'description': 'Clay',
  'description_tamil': 'களிமண்',
  'images': ['https://example.com/brick.jpg'],
  'thumbnail': null,
  'brand': 'BM',
  'unit': 'piece',
  'minimum_order_quantity': 500,
  'stock_status': 'lowStock',
  'stock_quantity': 10,
  'specifications': {'size': '20mm'},
  'keywords': ['brick'],
  'is_popular': true,
  'is_featured': false,
  'is_active': true,
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};
Map<String, dynamic> session([Map<String, dynamic> identity = user]) {
  final claims = base64Url
      .encode(utf8.encode(jsonEncode({
        'sub': uid,
        'exp': DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000
      })))
      .replaceAll('=', '');
  // Unsigned SDK fixture, never accepted by a server or shipped in app code.
  return {
    'access_token': 'eyJhbGciOiJIUzI1NiJ9.$claims.fixture',
    'refresh_token': 'fixture',
    'expires_in': 3600,
    'token_type': 'bearer',
    'user': identity
  };
}

http.Response response(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {
      'content-type': 'application/json',
      'x-supabase-api-version': '2024-01-01'
    });
sb.SupabaseClient clientFor(
    Future<http.Response> Function(http.Request) handler) {
  final client = sb.SupabaseClient(config.url, config.publishableKey,
      authOptions: const sb.AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
    final result = await handler(request);
    return http.Response.bytes(result.bodyBytes, result.statusCode,
        headers: result.headers, request: request);
  }));
  addTearDown(client.dispose);
  return client;
}

void main() {
  test(
      'configuration rejects secret/legacy keys, HTTP and credential-bearing URLs',
      () {
    expect(config.isValidSupabase, isTrue);
    for (final key in ['sb_secret_never_use', 'eyJhbGci.fixture', '']) {
      expect(
          BackendConfig(
                  backend: BackendKind.supabase,
                  url: config.url,
                  publishableKey: key)
              .isValidSupabase,
          isFalse);
    }
    for (final url in [
      'http://example.com',
      'https://user:pass@example.com',
      'https://example.com/path',
      'https://example.com?key=x'
    ]) {
      expect(
          BackendConfig(
                  backend: BackendKind.supabase,
                  url: url,
                  publishableKey: config.publishableKey)
              .isValidSupabase,
          isFalse);
    }
  });
  test(
      'OTP send does not create a session; verify uses the same phone and SMS type',
      () async {
    final requests = <http.Request>[];
    final client = clientFor((r) async {
      requests.add(r);
      return response(r.url.path.endsWith('/verify') ? session() : {});
    });
    final auth = SupabasePhoneAuthService(client);
    final event = (await auth.requestOtp(phoneNumber: phone).toList()).single
        as PhoneCodeSentEvent;
    expect(event.verificationId, phone);
    expect(client.auth.currentSession, isNull);
    final result = await auth.verifyOtp(
        verificationId: event.verificationId, smsCode: '123456');
    expect(result.user?.uid, uid);
    expect(result.user?.phoneNumber, phone);
    final payload = jsonDecode(requests.last.body) as Map;
    expect(payload['type'], 'sms');
    expect(payload['phone'], phone);
    expect(payload['token'], '123456');
    expect(requests.first.url.path, '/auth/v1/otp');
  });
  test('resend delegates rate limits to Supabase; no local OTP bypass',
      () async {
    var sends = 0;
    final auth = SupabasePhoneAuthService(clientFor((r) async {
      sends++;
      return response(
          {'code': 'over_sms_send_rate_limit', 'msg': 'internal details'}, 429);
    }));
    await expectLater(
        auth.requestOtp(phoneNumber: phone, forceResend: true),
        emitsError(isA<AuthFailure>()
            .having((e) => e.code, 'code', 'too-many-requests')));
    expect(sends, 1);
  });
  test('expired OTP and disabled provider have safe localized errors',
      () async {
    final expired = SupabasePhoneAuthService(clientFor((r) async =>
        response({'code': 'otp_expired', 'msg': 'private details'}, 403)));
    await expectLater(
        expired.verifyOtp(verificationId: phone, smsCode: '123456'),
        throwsA(
            isA<AuthFailure>().having((e) => e.code, 'code', 'invalidOtp')));
    final disabled = SupabasePhoneAuthService(clientFor((r) async => response(
        {'code': 'phone_provider_disabled', 'msg': 'private details'}, 400)));
    await expectLater(
        disabled.requestOtp(phoneNumber: phone),
        emitsError(isA<AuthFailure>()
            .having((e) => e.code, 'code', 'operation-not-allowed')));
    expect(
        AppLocalizations(const Locale('ta')).authError('operation-not-allowed'),
        isNot(contains('private')));
  });
  test('malformed phone/code never sends an HTTP request', () async {
    var calls = 0;
    final auth = SupabasePhoneAuthService(clientFor((r) async {
      calls++;
      return response({});
    }));
    await expectLater(
        auth.requestOtp(phoneNumber: '123'), emitsError(isA<AuthFailure>()));
    await expectLater(auth.verifyOtp(verificationId: phone, smsCode: 'abcdef'),
        throwsA(isA<AuthFailure>()));
    expect(calls, 0);
  });
  test('unverified identity and null session cannot pass OTP completion',
      () async {
    final auth = SupabasePhoneAuthService(clientFor(
        (r) async => response(session({...user, 'phone_confirmed_at': null}))));
    await expectLater(auth.verifyOtp(verificationId: phone, smsCode: '123456'),
        throwsA(isA<AuthFailure>()));
    expect(
        supabaseIdentity(
                sb.User.fromJson({...user, 'phone_confirmed_at': null})!)
            .phoneNumber,
        isNull);
  });
  test('profile save verifies server identity and updates only name', () async {
    final requests = <http.Request>[];
    var name = '';
    final client = clientFor((r) async {
      requests.add(r);
      if (r.url.path.endsWith('/verify')) return response(session());
      if (r.url.path.endsWith('/user')) return response(user);
      if (r.method == 'PATCH') {
        name = (jsonDecode(r.body) as Map)['name'] as String;
        return response({});
      }
      return response({
        'id': uid,
        'name': name,
        'phone_number': phone,
        'phone_verified': true,
        'is_active': true,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z'
      });
    });
    await SupabasePhoneAuthService(client)
        .verifyOtp(verificationId: phone, smsCode: '123456');
    final profile = await SupabaseCustomerRepository(client)
        .saveVerifiedCustomer(
            user: const AuthIdentity(uid: uid, phoneNumber: phone),
            name: 'Test Customer',
            phoneNumber: phone);
    expect(profile.name, 'Test Customer');
    expect(jsonDecode(requests.singleWhere((r) => r.method == 'PATCH').body),
        {'name': 'Test Customer'});
    expect(
        requests.where(
            (r) => r.method == 'POST' && r.url.path.endsWith('/profiles')),
        isEmpty);
  });
  test('read-only catalog maps existing models and bounded page parameters',
      () async {
    final requests = <http.Request>[];
    final repo = SupabaseCatalogRepository(clientFor((r) async {
      requests.add(r);
      return response([productRow]);
    }));
    final products = await repo.page(
        categoryId: 'bricks', query: '  செங்கல் ', afterId: 'a', limit: 100);
    expect(products.single.nameTamil, 'செங்கல்');
    expect(products.single.canOrder, isTrue);
    expect(products.single.minimumOrderQuantity, 500);
    expect(jsonDecode(requests.single.body), {
      'p_category': 'bricks',
      'p_query': 'செங்கல்',
      'p_after': 'a',
      'p_limit': 50,
      'p_popular': false
    });
  });
  test('missing price remains null and uses server-time RPC', () async {
    final requests = <http.Request>[];
    final repo = SupabaseCatalogRepository(clientFor((r) async {
      requests.add(r);
      return response([]);
    }));
    expect(await repo.currentPrice('brick', 'karaikudi'), isNull);
    expect(requests.single.url.path, '/rest/v1/rpc/current_product_price');
    expect(jsonDecode(requests.single.body),
        {'p_product_id': 'brick', 'p_location_id': 'karaikudi'});
  });
  test('numeric price and status mapping fail safely', () {
    final row = <String, dynamic>{
      'id': 'p',
      'product_id': 'brick',
      'location_id': 'k',
      'price': 8.5,
      'effective_from': '2026-01-01T00:00:00Z'
    };
    expect(SupabaseCatalogMapping.price(row).price, 8.5);
    expect(() => SupabaseCatalogMapping.price({...row, 'price': '₹8.50'}),
        throwsA(isA<TypeError>()));
    expect(
        SupabaseCatalogMapping.product(
            {...productRow, 'stock_status': 'unknown'}).canOrder,
        isFalse);
    expect(
        SupabaseCatalogMapping.product(
            {...productRow, 'stock_status': 'outOfStock'}).canOrder,
        isFalse);
  });
  test(
      'Supabase mode cannot fall back to demo or Firebase operational services',
      () async {
    final container = ProviderContainer(
        overrides: [backendConfigProvider.overrideWithValue(config)]);
    addTearDown(container.dispose);
    expect(container.read(demoCatalogProvider), isFalse);
    await expectLater(container.read(categoriesProvider.future),
        throwsA(isA<BackendUnavailable>()));
    await expectLater(container.read(orderRepositoryProvider).getUserOrders(),
        throwsA(isA<OrderFailure>()));
    await expectLater(
        container.read(adminSignInProvider)(
            email: 'fixture@example.com', password: 'fixture'),
        throwsA(isA<AdminFailure>()
            .having((e) => e.code, 'code', 'migrationPending')));
    expect(await container.read(notificationServiceProvider).permissionState(),
        NotificationPermissionState.unavailable);
    expect(await container.read(authStateProvider.future), isNull);
  });
}

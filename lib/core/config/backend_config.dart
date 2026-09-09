import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum BackendKind { firebase, supabase }

class BackendConfig {
  const BackendConfig(
      {this.backend = BackendKind.firebase,
      this.url = '',
      this.publishableKey = ''});
  final BackendKind backend;
  final String url;
  final String publishableKey;

  factory BackendConfig.fromEnvironment() {
    const name = String.fromEnvironment('BM_BACKEND', defaultValue: 'firebase');
    if (name != 'firebase' && name != 'supabase') {
      throw const FormatException('Invalid BM_BACKEND');
    }
    return BackendConfig(
        backend:
            name == 'supabase' ? BackendKind.supabase : BackendKind.firebase,
        url: const String.fromEnvironment('BM_SUPABASE_URL'),
        publishableKey:
            const String.fromEnvironment('BM_SUPABASE_PUBLISHABLE_KEY'));
  }

  bool get isSupabase => backend == BackendKind.supabase;
  bool get isValidSupabase {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        (uri.path.isEmpty || uri.path == '/') &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        RegExp(r'^sb_publishable_[A-Za-z0-9_-]+$').hasMatch(publishableKey);
  }
}

final backendConfigProvider =
    Provider<BackendConfig>((_) => BackendConfig.fromEnvironment());
// This is set only after successful SDK initialization. No Firebase fallback.
SupabaseClient? initializedSupabaseClient;
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final config = ref.watch(backendConfigProvider);
  if (!config.isSupabase ||
      !config.isValidSupabase ||
      initializedSupabaseClient == null) {
    throw const BackendUnavailable();
  }
  return initializedSupabaseClient!;
});

class BackendUnavailable implements Exception {
  const BackendUnavailable();
}

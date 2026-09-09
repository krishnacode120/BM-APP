import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/business_settings.dart';
import '../../repositories/business_settings_repository.dart';
import '../../core/config/backend_config.dart';

final businessSettingsRepositoryProvider = Provider<BusinessSettingsRepository>(
    (ref) => ref.watch(backendConfigProvider).isSupabase
        ? throw const BackendUnavailable()
        : Firebase.apps.isEmpty
            ? const DevelopmentBusinessSettingsRepository()
            : FirestoreBusinessSettingsRepository(FirebaseFirestore.instance));

final businessSettingsProvider = FutureProvider<BusinessSettings>(
    (ref) => ref.watch(businessSettingsRepositoryProvider).load());

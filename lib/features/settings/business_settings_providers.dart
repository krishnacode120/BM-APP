import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/business_settings.dart';
import '../../repositories/business_settings_repository.dart';

final businessSettingsRepositoryProvider = Provider<BusinessSettingsRepository>(
    (_) => Firebase.apps.isEmpty
        ? const DevelopmentBusinessSettingsRepository()
        : FirestoreBusinessSettingsRepository(FirebaseFirestore.instance));

final businessSettingsProvider = FutureProvider<BusinessSettings>(
    (ref) => ref.watch(businessSettingsRepositoryProvider).load());

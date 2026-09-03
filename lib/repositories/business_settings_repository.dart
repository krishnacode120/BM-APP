import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/business_settings.dart';

abstract interface class BusinessSettingsRepository {
  Future<BusinessSettings> load();
}

class FirestoreBusinessSettingsRepository
    implements BusinessSettingsRepository {
  FirestoreBusinessSettingsRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Future<BusinessSettings> load() async {
    final document = await _db.collection('settings').doc('app').get();
    return document.exists
        ? BusinessSettings.fromFirestore(document)
        : BusinessSettings.developmentFallback;
  }
}

class DevelopmentBusinessSettingsRepository
    implements BusinessSettingsRepository {
  const DevelopmentBusinessSettingsRepository();

  @override
  Future<BusinessSettings> load() async => BusinessSettings.developmentFallback;
}

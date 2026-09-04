import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class ProductMediaFailure implements Exception {
  const ProductMediaFailure(this.code);
  final String code;
}

abstract interface class ProductMediaRepository {
  Future<String> upload({
    required String productId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  });
}

class FirebaseProductMediaRepository implements ProductMediaRepository {
  FirebaseProductMediaRepository(this.storage);
  final FirebaseStorage storage;

  @override
  Future<String> upload({
    required String productId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    if (bytes.isEmpty || bytes.lengthInBytes > 5 * 1024 * 1024) {
      throw const ProductMediaFailure('invalid-image');
    }
    if (!contentType.startsWith('image/')) {
      throw const ProductMediaFailure('invalid-image');
    }
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    try {
      final reference = storage.ref(
        'products/$productId/${DateTime.now().millisecondsSinceEpoch}_$safeName',
      );
      await reference.putData(
          bytes, SettableMetadata(contentType: contentType));
      return await reference.getDownloadURL();
    } on FirebaseException catch (error) {
      throw ProductMediaFailure(error.code);
    }
  }
}

class UnavailableProductMediaRepository implements ProductMediaRepository {
  const UnavailableProductMediaRepository();

  @override
  Future<String> upload({
    required String productId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) =>
      throw const ProductMediaFailure('firebaseUnavailable');
}

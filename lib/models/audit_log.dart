import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLog {
  const AuditLog({
    required this.id,
    required this.actorUserId,
    required this.actorRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.createdAt,
  });
  final String id;
  final String actorUserId;
  final String actorRole;
  final String action;
  final String entityType;
  final String entityId;
  final DateTime createdAt;

  factory AuditLog.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    return AuditLog(
      id: document.id,
      actorUserId: data['actorUserId'] as String? ?? '',
      actorRole: data['actorRole'] as String? ?? '',
      action: data['action'] as String? ?? '',
      entityType: data['entityType'] as String? ?? '',
      entityId: data['entityId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

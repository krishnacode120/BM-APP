import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportSyncStatus {
  pending,
  processing,
  retrying,
  completed,
  failed,
  deadLetter,
  synced
}

ReportSyncStatus reportSyncStatusFromValue(String? value) =>
    ReportSyncStatus.values.firstWhere(
        (status) =>
            status.name == value ||
            (status == ReportSyncStatus.deadLetter && value == 'DEAD_LETTER') ||
            (status == ReportSyncStatus.completed && value == 'COMPLETED') ||
            (status == ReportSyncStatus.pending && value == 'PENDING') ||
            (status == ReportSyncStatus.processing && value == 'PROCESSING') ||
            (status == ReportSyncStatus.retrying && value == 'RETRYING') ||
            (status == ReportSyncStatus.failed && value == 'FAILED') ||
            (status == ReportSyncStatus.synced && value == 'SYNCED'),
        orElse: () => ReportSyncStatus.pending);

class ReportSyncJob {
  const ReportSyncJob({
    required this.orderId,
    required this.status,
    required this.attemptCount,
    required this.updatedAt,
    this.orderNumber,
    this.lastError,
    this.completedAt,
  });

  final String orderId;
  final String? orderNumber;
  final ReportSyncStatus status;
  final int attemptCount;
  final DateTime updatedAt;
  final String? lastError;
  final DateTime? completedAt;

  bool get needsAttention =>
      status == ReportSyncStatus.failed ||
      status == ReportSyncStatus.deadLetter;

  factory ReportSyncJob.fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> document) =>
      ReportSyncJob(
        orderId: document.data()?['entityId'] as String? ?? document.id,
        status:
            reportSyncStatusFromValue(document.data()?['status'] as String?),
        attemptCount: (document.data()?['attemptCount'] as num? ?? 0).toInt(),
        updatedAt: _date(document.data()?['updatedAt']),
        orderNumber: document.data()?['orderNumber'] as String?,
        lastError: document.data()?['lastError'] as String?,
        completedAt: _nullableDate(document.data()?['completedAt']),
      );
}

DateTime _date(Object? value) => _nullableDate(value) ?? DateTime(1970);

DateTime? _nullableDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

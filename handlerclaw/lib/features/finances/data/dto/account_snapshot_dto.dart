import 'package:handlerclaw/features/finances/domain/entities/account_snapshot_entity.dart';

class AccountSnapshotDto {
  final String id;
  final String accountId;
  final double amount;
  final DateTime date;
  final String? note;

  AccountSnapshotDto({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.date,
    this.note,
  });

  factory AccountSnapshotDto.fromJson(Map<String, dynamic> json) {
    return AccountSnapshotDto(
      id: json['id'],
      accountId: json['account_id'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  AccountSnapshotEntity toEntity() {
    return AccountSnapshotEntity(
      id: id,
      accountId: accountId,
      amount: amount,
      date: date,
      note: note,
    );
  }
}

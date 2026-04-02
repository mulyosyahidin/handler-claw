class AccountSnapshotEntity {
  final String id;
  final String accountId;
  final double amount;
  final DateTime date;
  final String? note;

  AccountSnapshotEntity({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.date,
    this.note,
  });
}

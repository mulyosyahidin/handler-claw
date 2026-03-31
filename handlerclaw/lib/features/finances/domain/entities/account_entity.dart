class AccountEntity {
  final String id;
  final String name;
  final String category;
  final double currentAmount;
  final String accountTypeId;

  AccountEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.currentAmount,
    required this.accountTypeId,
  });
}

class AccountsResultEntity {
  final List<AccountEntity> accounts;
  final int total;
  final int page;
  final int perPage;

  AccountsResultEntity({
    required this.accounts,
    required this.total,
    required this.page,
    required this.perPage,
  });
}

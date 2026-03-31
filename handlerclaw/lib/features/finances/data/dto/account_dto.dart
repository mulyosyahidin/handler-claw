class AccountDto {
  final String id;
  final String name;
  final String category;
  final double currentAmount;
  final String accountTypeId;

  AccountDto({
    required this.id,
    required this.name,
    required this.category,
    required this.currentAmount,
    required this.accountTypeId,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return AccountDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'LIQUID',
      currentAmount: (json['current_amount'] ?? 0).toDouble(),
      accountTypeId: json['account_type_id'] ?? '',
    );
  }
}

class Treasury {
  final int? id;
  final String name;
  final String currency;
  final String? accountCode;
  final double balance;
  final DateTime createdAt;

  Treasury({
    this.id,
    required this.name,
    required this.currency,
    this.accountCode,
    required this.balance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'account_code': accountCode,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Treasury.fromMap(Map<String, dynamic> map) {
    return Treasury(
      id: map['id'],
      name: map['name'],
      currency: map['currency'],
      accountCode: map['account_code'],
      balance: map['balance'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

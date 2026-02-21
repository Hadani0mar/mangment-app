class BankCard {
  final int? id;
  final String cardNumber;
  final String holderName;
  final String? phoneNumber;
  final String? nationalId;
  final String bankName;
  final String referenceCode;
  final bool isReserved;
  final bool isDeposited;
  final double limitUSD;
  final double spentUSD;
  final String status; // 'جديدة', 'محجوزة', 'تم الإيداع', 'مرسلة للسحب', 'مكتملة'
  final int? treasuryId;
  final DateTime createdAt;

  BankCard({
    this.id,
    required this.cardNumber,
    required this.holderName,
    this.phoneNumber,
    this.nationalId,
    required this.bankName,
    required this.referenceCode,
    this.isReserved = false,
    this.isDeposited = false,
    this.limitUSD = 10000.0,
    this.spentUSD = 0.0,
    this.status = 'جديدة',
    this.treasuryId,
    required this.createdAt,
  });

  double get remainingUSD => limitUSD - spentUSD;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_number': cardNumber,
      'holder_name': holderName,
      'phone_number': phoneNumber,
      'national_id': nationalId,
      'bank_name': bankName,
      'reference_code': referenceCode,
      'is_reserved': isReserved ? 1 : 0,
      'is_deposited': isDeposited ? 1 : 0,
      'limit_usd': limitUSD,
      'spent_usd': spentUSD,
      'status': status,
      'treasury_id': treasuryId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BankCard.fromMap(Map<String, dynamic> map) {
    return BankCard(
      id: map['id'],
      cardNumber: map['card_number'],
      holderName: map['holder_name'],
      phoneNumber: map['phone_number'],
      nationalId: map['national_id'],
      bankName: map['bank_name'],
      referenceCode: map['reference_code'],
      isReserved: map['is_reserved'] == 1,
      isDeposited: map['is_deposited'] == 1,
      limitUSD: (map['limit_usd'] ?? 10000.0).toDouble(),
      spentUSD: (map['spent_usd'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'جديدة',
      treasuryId: map['treasury_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

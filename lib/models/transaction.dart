enum TransactionType { deposit, withdraw, transfer, exchange }

class TransactionRecord {
  final int? id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? note;
  final int treasuryId;
  final int? relatedTreasuryId;

  TransactionRecord({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
    required this.treasuryId,
    this.relatedTreasuryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'treasury_id': treasuryId,
      'related_treasury_id': relatedTreasuryId,
    };
  }

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      id: map['id'],
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      treasuryId: map['treasury_id'],
      relatedTreasuryId: map['related_treasury_id'],
    );
  }
}

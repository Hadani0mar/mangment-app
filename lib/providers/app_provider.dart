import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/treasury.dart';
import '../models/transaction.dart';
import '../models/bank_card.dart';
import '../services/database_helper.dart';

class AppProvider with ChangeNotifier {
  List<Treasury> _treasuries = [];
  List<TransactionRecord> _transactions = [];
  List<BankCard> _cards = [];

  List<Treasury> get treasuries => _treasuries;
  List<TransactionRecord> get transactions => _transactions;
  List<BankCard> get cards => _cards;

  final dbHelper = DatabaseHelper.instance;

  Future<void> init() async {
    await fetchTreasuries();
    await fetchTransactions();
    await fetchCards();
  }

  // --- Treasury Management ---

  Future<void> fetchTreasuries() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('treasuries');
    _treasuries = List.generate(maps.length, (i) => Treasury.fromMap(maps[i]));
    notifyListeners();
  }

  Future<void> addTreasury(Treasury treasury) async {
    final db = await dbHelper.database;
    await db.insert('treasuries', treasury.toMap());
    await fetchTreasuries();
  }

  Future<void> updateTreasury(Treasury treasury) async {
    final db = await dbHelper.database;
    await db.update(
      'treasuries',
      treasury.toMap(),
      where: 'id = ?',
      whereArgs: [treasury.id],
    );
    await fetchTreasuries();
  }

  Future<void> deleteTreasury(int id) async {
    final db = await dbHelper.database;
    await db.delete('treasuries', where: 'id = ?', whereArgs: [id]);
    await fetchTreasuries();
  }

  // --- Transaction Management ---

  Future<void> fetchTransactions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    _transactions = List.generate(maps.length, (i) => TransactionRecord.fromMap(maps[i]));
    notifyListeners();
  }

  Future<void> addTransaction(TransactionRecord transaction) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      await txn.insert('transactions', transaction.toMap());

      if (transaction.type == TransactionType.deposit) {
        await txn.execute(
            'UPDATE treasuries SET balance = balance + ? WHERE id = ?',
            [transaction.amount, transaction.treasuryId]);
      } else if (transaction.type == TransactionType.withdraw) {
        await txn.execute(
            'UPDATE treasuries SET balance = balance - ? WHERE id = ?',
            [transaction.amount, transaction.treasuryId]);
      } else if (transaction.type == TransactionType.transfer) {
        await txn.execute(
            'UPDATE treasuries SET balance = balance - ? WHERE id = ?',
            [transaction.amount, transaction.treasuryId]);
        await txn.execute(
            'UPDATE treasuries SET balance = balance + ? WHERE id = ?',
            [transaction.amount, transaction.relatedTreasuryId]);
      } else if (transaction.type == TransactionType.exchange) {
        // Source deduction
        await txn.execute(
            'UPDATE treasuries SET balance = balance - ? WHERE id = ?',
            [transaction.amount, transaction.treasuryId]);
        // Note: The destination amount should be handled by the caller or passed in.
        // For simplicity, let's assume the transaction record 'amount' is what's deducted from source,
        // and we might need another field for destination amount if it differs due to exchange rate.
        // For now, let's just stick to the basic logic or improve the model.
      }
    });

    await fetchTreasuries();
    await fetchTransactions();
  }

  // Currency Exchange with specific logic
  Future<void> performExchange({
    required int sourceId,
    required int destId,
    required double sourceAmount,
    required double rate,
    String? note,
  }) async {
    final db = await dbHelper.database;
    final destAmount = sourceAmount * rate;

    await db.transaction((txn) async {
      // Record transaction for source
      await txn.insert('transactions', {
        'type': TransactionType.exchange.name,
        'amount': sourceAmount,
        'date': DateTime.now().toIso8601String(),
        'note': 'Exchange to $destId: $note',
        'treasury_id': sourceId,
        'related_treasury_id': destId,
      });

      // Update source
      await txn.execute(
          'UPDATE treasuries SET balance = balance - ? WHERE id = ?',
          [sourceAmount, sourceId]);

      // Update destination
      await txn.execute(
          'UPDATE treasuries SET balance = balance + ? WHERE id = ?',
          [destAmount, destId]);
    });

    await fetchTreasuries();
    await fetchTransactions();
  }

  Future<void> performCurrencyPurchase({
    required int lydTreasuryId,
    required int usdTreasuryId,
    required double usdAmount,
    required double rate,
    String? note,
  }) async {
    final db = await dbHelper.database;
    final totalLydCost = usdAmount * rate;

    await db.transaction((txn) async {
      // 1. Deduct LYD from source
      await txn.execute(
          'UPDATE treasuries SET balance = balance - ? WHERE id = ?',
          [totalLydCost, lydTreasuryId]);

      // 2. Add USD to target
      await txn.execute(
          'UPDATE treasuries SET balance = balance + ? WHERE id = ?',
          [usdAmount, usdTreasuryId]);

      // 3. Record Transactions
      await txn.insert('transactions', {
        'type': TransactionType.withdraw.name,
        'amount': totalLydCost,
        'date': DateTime.now().toIso8601String(),
        'note': 'شراء عملة (\$${usdAmount.toStringAsFixed(0)}) بسعر $rate. $note',
        'treasury_id': lydTreasuryId,
      });

      await txn.insert('transactions', {
        'type': TransactionType.deposit.name,
        'amount': usdAmount,
        'date': DateTime.now().toIso8601String(),
        'note': 'دخول شراء عملة مقابل خصم من الخزينة $lydTreasuryId. $note',
        'treasury_id': usdTreasuryId,
      });
    });

    await fetchTreasuries();
    await fetchTransactions();
  }

  // --- Bank Card Management ---

  Future<void> fetchCards() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('bank_cards');
    _cards = List.generate(maps.length, (i) => BankCard.fromMap(maps[i]));
    notifyListeners();
  }

  Future<String> generateUniqueReferenceCode() async {
    final db = await dbHelper.database;
    final random = Random();
    while (true) {
      String code = (random.nextInt(9000) + 1000).toString(); // 1000-9999
      final List<Map<String, dynamic>> maps = await db.query('bank_cards',
          where: 'reference_code = ?', whereArgs: [code]);
      if (maps.isEmpty) return code;
    }
  }

  Future<void> addCard(BankCard card, {double? depositAmount}) async {
    final db = await dbHelper.database;
    
    await db.transaction((txn) async {
      await txn.insert('bank_cards', card.toMap());
      
      // If card is already deposited at creation, deduct from treasury
      if (card.isDeposited && card.treasuryId != null && depositAmount != null && depositAmount > 0) {
        await txn.insert('transactions', {
          'type': TransactionType.withdraw.name,
          'amount': depositAmount,
          'date': DateTime.now().toIso8601String(),
          'note': 'إيداع بطاقة: ${card.cardNumber}',
          'treasury_id': card.treasuryId,
        });
        
        await txn.execute(
            'UPDATE treasuries SET balance = balance - ? WHERE id = ?',
            [depositAmount, card.treasuryId]);
      }
    });

    await fetchCards();
    await fetchTreasuries();
    await fetchTransactions();
  }
  
  Future<void> markCardAsDeposited(int cardId, int treasuryId, double amount) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.update('bank_cards', 
        {'is_deposited': 1, 'is_reserved': 1, 'status': 'تم الإيداع', 'treasury_id': treasuryId},
        where: 'id = ?', whereArgs: [cardId]
      );
      
      await txn.insert('transactions', {
        'type': TransactionType.withdraw.name,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'note': 'خصم قيمة إيداع بطاقة',
        'treasury_id': treasuryId,
      });
      
      await txn.execute(
          'UPDATE treasuries SET balance = balance - ? WHERE id = ?',
          [amount, treasuryId]);
    });
    
    await fetchCards();
    await fetchTreasuries();
    await fetchTransactions();
  }

  Future<void> clearAllData() async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('bank_cards');
      await txn.delete('treasuries');
    });
    await init();
  }

  Future<void> updateCard(BankCard card) async {
    final db = await dbHelper.database;
    await db.update(
      'bank_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
    await fetchCards();
  }

  Future<void> deleteCard(int id) async {
    final db = await dbHelper.database;
    await db.delete('bank_cards', where: 'id = ?', whereArgs: [id]);
    await fetchCards();
  }

  // --- Search & Filters ---
  List<TransactionRecord> getTransactionsByTreasury(int treasuryId) {
    return _transactions.where((tx) => tx.treasuryId == treasuryId || tx.relatedTreasuryId == treasuryId).toList();
  }
}

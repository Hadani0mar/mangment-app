import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../models/treasury.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Import new operation screens
import 'operations/deposit_operation.dart';
import 'operations/withdraw_operation.dart';
import 'operations/transfer_operation.dart';
import 'operations/exchange_operation.dart';
import 'operations/purchase_operation.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final transactions = provider.transactions.where((t) => 
      (t.note?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
      _getTypeLabel(t.type).contains(searchQuery)
    ).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'بحث في سجل العمليات...',
                      prefixIcon: Icon(Ionicons.search_outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final treasury = provider.treasuries.firstWhere((t) => t.id == tx.treasuryId, orElse: () => Treasury(name: 'مجهول', currency: '', balance: 0, createdAt: DateTime.now()));
                    
                    return _buildTransactionCard(context, tx, treasury).animate().slideX(begin: 0.1, delay: (index * 30).ms).fadeIn();
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionRecord tx, Treasury treasury) {
    Color statusColor = tx.type == TransactionType.deposit ? const Color(0xFF10B981) : 
                       tx.type == TransactionType.withdraw ? const Color(0xFFEF4444) : 
                       tx.type == TransactionType.transfer ? const Color(0xFF6366F1) : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getTypeIcon(tx.type), color: statusColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.note ?? _getTypeLabel(tx.type),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                Text(
                  '${treasury.name} • ${DateFormat('yyyy-MM-dd HH:mm').format(tx.date)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: statusColor),
              ),
              Text(
                _getTypeLabel(tx.type),
                style: TextStyle(color: statusColor.withOpacity(0.7), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit: return Ionicons.arrow_down_outline;
      case TransactionType.withdraw: return Ionicons.arrow_up_outline;
      case TransactionType.transfer: return Ionicons.swap_horizontal_outline;
      case TransactionType.exchange: return Ionicons.repeat_outline;
    }
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit: return 'إيداع';
      case TransactionType.withdraw: return 'سحب';
      case TransactionType.transfer: return 'تحويل';
      case TransactionType.exchange: return 'صرافة';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.receipt_outline, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          const Text('لا يوجد سجل عمليات حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

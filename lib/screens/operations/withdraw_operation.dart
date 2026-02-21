import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/transaction.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WithdrawOperationScreen extends StatefulWidget {
  const WithdrawOperationScreen({super.key});

  @override
  State<WithdrawOperationScreen> createState() => _WithdrawOperationScreenState();
}

class _WithdrawOperationScreenState extends State<WithdrawOperationScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedTreasuryId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('عملية سحب مال', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: [
                       const Icon(Ionicons.remove_circle, size: 40, color: Colors.red),
                       const SizedBox(height: 12),
                       const Text(
                        'سحب رصيد مالي',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<int>(
                        value: _selectedTreasuryId,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          labelText: 'السحب من خزينة',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.wallet_outline, size: 20, color: Color(0xFF64748B)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                        ),
                        items: provider.treasuries.map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text('${t.name} (${t.currency})'),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedTreasuryId = val),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          labelText: 'المبلغ المسحوب',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.cash_outline, size: 20, color: Color(0xFF64748B)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          labelText: 'سبب السحب / ملاحظات',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.document_text_outline, size: 20, color: Color(0xFF64748B)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleWithdraw(context),
                    child: const Text('تأكيد السحب', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleWithdraw(BuildContext context) {
    if (_selectedTreasuryId == null) {
      _showModernDialog(
        context: context,
        title: 'بيانات ناقصة',
        message: 'يرجى اختيار الخزينة لإتمام عملية السحب.',
        icon: Ionicons.alert_circle,
        color: Colors.orange,
      );
      return;
    }
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      _showModernDialog(
        context: context,
        title: 'مبلغ غير صالح',
        message: 'يرجى إدخال مبلغ صحيح أكبر من الصفر.',
        icon: Ionicons.alert_circle,
        color: Colors.orange,
      );
      return;
    }

    final provider = context.read<AppProvider>();
    final treasury = provider.treasuries.firstWhere((t) => t.id == _selectedTreasuryId);

    if (treasury.balance < amount) {
      _showModernDialog(
        context: context,
        title: 'رصيد غير كافٍ',
        message: 'لا يوجد رصيد كافٍ في هذه الخزينة لإتمام عملية السحب.',
        icon: Ionicons.close_circle,
        color: Colors.red,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Ionicons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد السحب', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('سيتم سحب مبلغ $amount من الخزينة المحددة، هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              provider.addTransaction(
                TransactionRecord(
                  treasuryId: _selectedTreasuryId!,
                  type: TransactionType.withdraw,
                  amount: amount,
                  date: DateTime.now(),
                  note: _noteController.text,
                )
              );
              Navigator.pop(context); // Pop screen
              _showModernDialog(
                context: context,
                title: 'تم السحب',
                message: 'تمت عملية السحب بنجاح.',
                icon: Ionicons.checkmark_circle,
                color: Colors.green,
              );
            },
            child: const Text('تأكيد السحب'),
          ),
        ],
      ),
    );
  }

  void _showModernDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color).animate().scale(duration: 200.ms),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

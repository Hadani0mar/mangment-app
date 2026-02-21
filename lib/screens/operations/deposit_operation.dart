import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/transaction.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DepositOperationScreen extends StatefulWidget {
  const DepositOperationScreen({super.key});

  @override
  State<DepositOperationScreen> createState() => _DepositOperationScreenState();
}

class _DepositOperationScreenState extends State<DepositOperationScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedTreasuryId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('عملية إيداع مال', style: TextStyle(fontWeight: FontWeight.w900)),
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
                       const Icon(Ionicons.add_circle, size: 40, color: Colors.green),
                       const SizedBox(height: 12),
                       const Text(
                        'إيداع رصيد جديد',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<int>(
                        value: _selectedTreasuryId,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          labelText: 'الخزينة المستهدفة',
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
                          labelText: 'المبلغ',
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
                          labelText: 'ملاحظات',
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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleDeposit(context),
                    child: const Text('تأكيد الإيداع', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDeposit(BuildContext context) {
    if (_selectedTreasuryId == null) {
      _showModernDialog(
        context: context,
        title: 'خطأ',
        message: 'يرجى اختيار الخزينة المستهدفة.',
        icon: Ionicons.alert_circle,
        color: Colors.orange,
      );
      return;
    }
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      _showModernDialog(
        context: context,
        title: 'خطأ',
        message: 'يرجى إدخال مبلغ صحيح أكبر من الصفر.',
        icon: Ionicons.alert_circle,
        color: Colors.orange,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Ionicons.information_circle, color: Colors.blue),
            SizedBox(width: 8),
            Text('تأكيد الإيداع', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('هل أنت متأكد من إيداع مبلغ $amount في الخزينة المحددة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppProvider>().addTransaction(
                TransactionRecord(
                  treasuryId: _selectedTreasuryId!,
                  type: TransactionType.deposit,
                  amount: amount,
                  date: DateTime.now(),
                  note: _noteController.text,
                )
              );
              Navigator.pop(context); // Pop screen
              _showModernDialog(
                context: context,
                title: 'نجاح',
                message: 'تمت عملية الإيداع بنجاح.',
                icon: Ionicons.checkmark_circle,
                color: Colors.green,
              );
            },
            child: const Text('تأكيد'),
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

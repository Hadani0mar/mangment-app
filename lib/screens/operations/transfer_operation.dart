import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/transaction.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransferOperationScreen extends StatefulWidget {
  const TransferOperationScreen({super.key});

  @override
  State<TransferOperationScreen> createState() => _TransferOperationScreenState();
}

class _TransferOperationScreenState extends State<TransferOperationScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _sourceTreasuryId;
  int? _destTreasuryId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('عملية تحويل بين الخزائن', style: TextStyle(fontWeight: FontWeight.w900)),
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
                       const Icon(Ionicons.swap_horizontal, size: 40, color: Colors.blue),
                       const SizedBox(height: 12),
                       const Text(
                        'تحويل رصيد داخلي',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<int>(
                        value: _sourceTreasuryId,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          labelText: 'من الخزينة (المصدر)',
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
                        onChanged: (val) => setState(() {
                          _sourceTreasuryId = val;
                          if (_destTreasuryId == val) _destTreasuryId = null;
                        }),
                      ),
                      const SizedBox(height: 12),
                      const Icon(Ionicons.arrow_down, color: Colors.grey, size: 18),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _destTreasuryId,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          labelText: 'إلى الخزينة (المستلم)',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.arrow_redo_outline, size: 20, color: Color(0xFF64748B)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                        ),
                        items: provider.treasuries.where((t) => t.id != _sourceTreasuryId).map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text('${t.name} (${t.currency})'),
                        )).toList(),
                        onChanged: (val) => setState(() => _destTreasuryId = val),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          labelText: 'المبلغ المراد تحويله',
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
                          labelText: 'بيان العملية / ملاحظات',
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
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleTransfer(context),
                    child: const Text('تأكيد التحويل الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTransfer(BuildContext context) {
    if (_sourceTreasuryId == null || _destTreasuryId == null) {
      _showModernDialog(
        context: context,
        title: 'بيانات ناقصة',
        message: 'يرجى اختيار الخزينة المصدر والخزينة المستلمة.',
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
    final source = provider.treasuries.firstWhere((t) => t.id == _sourceTreasuryId);
    
    if (source.balance < amount) {
      _showModernDialog(
        context: context,
        title: 'رصيد غير كافٍ',
        message: 'الرصيد في الخزينة المصدر غير كافٍ لإتمام التحويل.',
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
            Icon(Ionicons.swap_horizontal, color: Colors.blue),
            SizedBox(width: 8),
            Text('تأكيد التحويل', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('هل أنت متأكد من تحويل مبلغ $amount؟'),
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
              provider.addTransaction(
                TransactionRecord(
                  type: TransactionType.transfer,
                  amount: amount,
                  date: DateTime.now(),
                  note: _noteController.text,
                  treasuryId: _sourceTreasuryId!,
                  relatedTreasuryId: _destTreasuryId,
                )
              );
              Navigator.pop(context); // Pop screen
              _showModernDialog(
                context: context,
                title: 'تم التحويل',
                message: 'تمت عملية التحويل بنجاح.',
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

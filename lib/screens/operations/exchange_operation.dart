import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/transaction.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExchangeOperationScreen extends StatefulWidget {
  const ExchangeOperationScreen({super.key});

  @override
  State<ExchangeOperationScreen> createState() => _ExchangeOperationScreenState();
}

class _ExchangeOperationScreenState extends State<ExchangeOperationScreen> {
  final _amountController = TextEditingController();
  final _rateController = TextEditingController(text: '1.0');
  final _noteController = TextEditingController();
  int? _sourceTreasuryId;
  int? _destTreasuryId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('عملية صرف عملات', style: TextStyle(fontWeight: FontWeight.w900)),
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
                       const Icon(Ionicons.repeat, size: 40, color: Colors.orange),
                       const SizedBox(height: 12),
                       const Text(
                        'تبديل عملة مقابل عملة',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<int>(
                        value: _sourceTreasuryId,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          labelText: 'تقديم من الخزينة',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.remove_circle_outline, size: 20, color: Color(0xFF64748B)),
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
                      DropdownButtonFormField<int>(
                        value: _destTreasuryId,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          labelText: 'استلام في الخزينة',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.add_circle_outline, size: 20, color: Color(0xFF64748B)),
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
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _amountController,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                              decoration: const InputDecoration(
                                labelText: 'المبلغ المقدم',
                                labelStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Ionicons.cash_outline, size: 20, color: Color(0xFF64748B)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _rateController,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                              decoration: const InputDecoration(
                                labelText: 'السعر',
                                labelStyle: TextStyle(color: Color(0xFF64748B)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      if (_amountController.text.isNotEmpty && _rateController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('المستلم النهائي:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                Text(
                                  '${((double.tryParse(_amountController.text) ?? 0) * (double.tryParse(_rateController.text) ?? 1)).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          labelText: 'ملاحظات العملية',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.document_text_outline, size: 20, color: Color(0xFF64748B)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                        ),
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
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleExchange(context),
                    child: const Text('تنفيذ عملية الصرف', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleExchange(BuildContext context) {
    if (_sourceTreasuryId == null || _destTreasuryId == null) {
      _showModernDialog(
        context: context,
        title: 'بيانات ناقصة',
        message: 'يرجى اختيار الخزائن لعملية الصرف.',
        icon: Ionicons.alert_circle,
        color: Colors.orange,
      );
      return;
    }

    final sourceAmount = double.tryParse(_amountController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 1.0;
    if (sourceAmount <= 0) {
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
    
    if (source.balance < sourceAmount) {
      _showModernDialog(
        context: context,
        title: 'رصيد غير كافٍ',
        message: 'الرصيد في الخزينة المصدر غير كافٍ لإتمام عملية الصرف.',
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
            Icon(Ionicons.repeat, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد عملية الصرف', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('هل أنت متأكد من صرف ملبغ $sourceAmount بسعر $rate؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              provider.performExchange(
                sourceId: _sourceTreasuryId!,
                destId: _destTreasuryId!,
                sourceAmount: sourceAmount,
                rate: rate,
                note: _noteController.text,
              );
              Navigator.pop(context); // Pop screen
              _showModernDialog(
                context: context,
                title: 'تم الصرف',
                message: 'تمت عملية الصرف بنجاح.',
                icon: Ionicons.checkmark_circle,
                color: Colors.green,
              );
            },
            child: const Text('تأكيد الصرف'),
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

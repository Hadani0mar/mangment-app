import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PurchaseOperationScreen extends StatefulWidget {
  const PurchaseOperationScreen({super.key});

  @override
  State<PurchaseOperationScreen> createState() => _PurchaseOperationScreenState();
}

class _PurchaseOperationScreenState extends State<PurchaseOperationScreen> {
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _noteController = TextEditingController();
  int? _lydTreasuryId;
  int? _usdTreasuryId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('شراء عملة دولار (\$)', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.deepPurple,
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
                       const Icon(Ionicons.cart, size: 40, color: Colors.deepPurple),
                       const SizedBox(height: 12),
                       const Text(
                        'شراء دولار (\$)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<int>(
                        value: _lydTreasuryId,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          labelText: 'الخصم من (خزينة الدينار)',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.wallet_outline, size: 20, color: Color(0xFF64748B)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                        ),
                        items: provider.treasuries.where((t) => t.currency == 'LYD').map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        )).toList(),
                        onChanged: (val) => setState(() => _lydTreasuryId = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _usdTreasuryId,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          labelText: 'الإيداع في (خزينة الدولار)',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Ionicons.add_circle_outline, size: 20, color: Color(0xFF64748B)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                        ),
                        items: provider.treasuries.where((t) => t.currency == 'USD').map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        )).toList(),
                        onChanged: (val) => setState(() => _usdTreasuryId = val),
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
                                labelText: 'كمية الدولار',
                                labelStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Ionicons.logo_usd, size: 20, color: Color(0xFF64748B)),
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
                              color: Colors.deepPurple.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('التكلفة بالدينار:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                Text(
                                  '${((double.tryParse(_amountController.text) ?? 0) * (double.tryParse(_rateController.text) ?? 1)).toStringAsFixed(2)} LYD',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                                ),
                              ],
                            ),
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
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handlePurchase(context),
                    child: const Text('إتمام عملية الشراء', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context) {
    if (_lydTreasuryId == null || _usdTreasuryId == null) {
      _showModernDialog(
        context: context,
        title: 'بيانات ناقصة',
        message: 'يرجى اختيار خزينة الدينار وخزينة الدولار.',
        icon: Ionicons.alert_circle,
        color: Colors.orange,
      );
      return;
    }
    
    final usdAmount = double.tryParse(_amountController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    
    if (usdAmount <= 0 || rate <= 0) {
      _showModernDialog(
        context: context,
        title: 'مدخلات غير صالحة',
        message: 'يرجى إدخال مبلغ وسعر بشكل صحيح أكبر من الصفر.',
        icon: Ionicons.alert_circle,
        color: Colors.orange,
      );
      return;
    }

    final provider = context.read<AppProvider>();
    final lydTreasury = provider.treasuries.firstWhere((t) => t.id == _lydTreasuryId);
    final totalCost = usdAmount * rate;

    if (lydTreasury.balance < totalCost) {
      _showModernDialog(
        context: context,
        title: 'رصيد غير كافٍ',
        message: 'الرصيد في خزينة الدينار غير كافٍ لتغطية التكلفة.',
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
            Icon(Ionicons.cart, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('تأكيد عملية الشراء', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('هل أنت متأكد من دفع $totalCost د.ل مقابل $usdAmount دولار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              provider.performCurrencyPurchase(
                lydTreasuryId: _lydTreasuryId!,
                usdTreasuryId: _usdTreasuryId!,
                usdAmount: usdAmount,
                rate: rate,
                note: _noteController.text,
              );
              Navigator.pop(context); // Pop screen
              _showModernDialog(
                context: context,
                title: 'عملية ناجحة',
                message: 'تم شراء العملة بنجاح.',
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

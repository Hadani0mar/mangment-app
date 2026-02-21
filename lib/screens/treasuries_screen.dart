import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/treasury.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TreasuriesScreen extends StatelessWidget {
  const TreasuriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final treasuries = provider.treasuries;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: treasuries.isEmpty 
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: treasuries.length,
              itemBuilder: (context, index) {
                final treasury = treasuries[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Ionicons.wallet_outline, color: Color(0xFF6366F1), size: 24),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              treasury.name, 
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1E293B))
                            ),
                            Text(
                              '${treasury.currency} ${treasury.accountCode != null && treasury.accountCode!.isNotEmpty ? "• ${treasury.accountCode}" : ""}', 
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            treasury.balance.toStringAsFixed(2), 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF6366F1))
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Ionicons.create_outline, color: Colors.blue, size: 20),
                                onPressed: () => _showAddTreasuryDialog(context, treasury: treasury),
                              ),
                              IconButton(
                                icon: const Icon(Ionicons.trash_outline, color: Colors.red, size: 20),
                                onPressed: () => _showDeleteConfirmation(context, treasury),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().slideX(begin: 0.1, delay: (index * 50).ms).fadeIn();
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTreasuryDialog(context),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Ionicons.add),
        label: const Text('إضافة خزينة'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.server_outline, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          const Text('لا توجد خزائن مضافة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Treasury treasury) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('حذف الخزينة'),
        content: Text('هل أنت متأكد من حذف خزينة "${treasury.name}"؟ سيتم حذف كافة العمليات المرتبطة بها.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AppProvider>().deleteTreasury(treasury.id!);
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddTreasuryDialog(BuildContext context, {Treasury? treasury}) {
    final isEdit = treasury != null;
    final nameController = TextEditingController(text: treasury?.name);
    final currencyController = TextEditingController(text: treasury?.currency);
    final balanceController = TextEditingController(text: treasury?.balance.toString());
    final codeController = TextEditingController(text: treasury?.accountCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isEdit ? 'تعديل بيانات الخزينة' : 'إضافة خزينة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الخزينة', prefixIcon: Icon(Ionicons.business_outline))),
              const SizedBox(height: 12),
              TextField(controller: currencyController, decoration: const InputDecoration(labelText: 'العملة', prefixIcon: Icon(Ionicons.cash_outline))),
              const SizedBox(height: 12),
              if (!isEdit)
                TextField(controller: balanceController, decoration: const InputDecoration(labelText: 'الرصيد الافتتاحي', prefixIcon: Icon(Ionicons.wallet_outline)), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: codeController, decoration: const InputDecoration(labelText: 'كود الحساب (اختياري)', prefixIcon: Icon(Ionicons.code_outline))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (isEdit) {
                final updated = Treasury(
                  id: treasury.id,
                  name: nameController.text,
                  currency: currencyController.text,
                  balance: treasury.balance,
                  accountCode: codeController.text,
                  createdAt: treasury.createdAt,
                );
                context.read<AppProvider>().updateTreasury(updated);
              } else {
                final newTreasury = Treasury(
                  name: nameController.text,
                  currency: currencyController.text,
                  balance: double.tryParse(balanceController.text) ?? 0.0,
                  accountCode: codeController.text,
                  createdAt: DateTime.now(),
                );
                context.read<AppProvider>().addTreasury(newTreasury);
              }
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

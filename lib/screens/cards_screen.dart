import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/bank_card.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allCards = provider.cards;
    final filteredCards = allCards.where((c) => 
      c.referenceCode.toLowerCase().contains(searchQuery.toLowerCase()) || 
      c.holderName.toLowerCase().contains(searchQuery.toLowerCase()) ||
      c.bankName.toLowerCase().contains(searchQuery.toLowerCase()) ||
      c.cardNumber.contains(searchQuery)
    ).toList();

    double totalLimit = allCards.fold(0, (sum, item) => sum + item.limitUSD);
    double totalSpent = allCards.fold(0, (sum, item) => sum + item.spentUSD);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Dashboard Header for Cards
          _buildQuickStats(totalLimit, totalSpent, allCards.length),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'بحث بالكود، الاسم، أو رقم البطاقة...',
                      prefixIcon: Icon(Ionicons.search_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () => _showAddCardDialog(context),
                  elevation: 0,
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  child: const Icon(Ionicons.add),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredCards.isEmpty 
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 480,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
                    return _buildTradingCard(context, card).animate().scale(delay: (index * 50).ms);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(double limit, double spent, int count) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('إجمالي المخصصات', '\$${limit.toStringAsFixed(0)}', Ionicons.globe_outline, Colors.blue),
          _buildStatItem('المسحوب فعلياً', '\$${spent.toStringAsFixed(0)}', Ionicons.trending_up_outline, Colors.orange),
          _buildStatItem('عدد البطاقات', '$count', Ionicons.card_outline, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
      ],
    );
  }

  Widget _buildTradingCard(BuildContext context, BankCard card) {
    double progress = card.limitUSD > 0 ? (card.spentUSD / card.limitUSD) : 0;
    Color statusColor = _getStatusColor(card.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.bankName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B))),
                  Text('REF: ${card.referenceCode}', style: const TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  card.status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            card.holderName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          Text(
            card.cardNumber,
            style: TextStyle(fontSize: 12, color: Colors.grey[400], letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${card.spentUSD.toStringAsFixed(0)} مسحوب', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('\$${card.remainingUSD.toStringAsFixed(0)} متبقي', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              color: progress > 0.9 ? Colors.red : const Color(0xFF6366F1),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showEditCardDialog(context, card),
                icon: const Icon(Ionicons.options_outline, color: Colors.blueGrey),
                tooltip: 'تحديث الحالة والمبالغ',
              ),
              if (!card.isDeposited)
                ElevatedButton.icon(
                  onPressed: () => _showDepositConfirmation(context, card),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Ionicons.cash_outline, size: 16),
                  label: const Text('إيداع مال'),
                )
              else
                const Icon(Ionicons.checkmark_circle, color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جديدة': return Colors.grey;
      case 'محجوزة': return Colors.blue;
      case 'تم الإيداع': return Colors.orange;
      case 'مرسلة للسحب': return Colors.indigo;
      case 'مكتملة': return Colors.green;
      default: return Colors.blue;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.card_outline, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          const Text('لا يوجد بطاقات مضافة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) async {
    final provider = context.read<AppProvider>();
    final cardNoController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final bankController = TextEditingController();
    
    String refCode = await provider.generateUniqueReferenceCode();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('تسجيل بطاقة جديدة (REF: $refCode)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم صاحب البطاقة', prefixIcon: Icon(Ionicons.person_outline))),
                const SizedBox(height: 12),
                TextField(controller: cardNoController, decoration: const InputDecoration(labelText: 'رقم البطاقة (16 رقم)', prefixIcon: Icon(Ionicons.card_outline))),
                const SizedBox(height: 12),
                TextField(controller: bankController, decoration: const InputDecoration(labelText: 'اسم البنك', prefixIcon: Icon(Ionicons.business_outline))),
                const SizedBox(height: 12),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Ionicons.call_outline))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || cardNoController.text.isEmpty) return;
                
                final card = BankCard(
                  cardNumber: cardNoController.text,
                  holderName: nameController.text,
                  phoneNumber: phoneController.text,
                  bankName: bankController.text,
                  referenceCode: refCode,
                  createdAt: DateTime.now(),
                );
                provider.addCard(card);
                Navigator.pop(context);
              },
              child: const Text('تأكيد التسجيل'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCardDialog(BuildContext context, BankCard card) {
    final provider = context.read<AppProvider>();
    final spentController = TextEditingController(text: card.spentUSD.toString());
    String currentStatus = card.status;
    final statuses = ['جديدة', 'محجوزة', 'تم الإيداع', 'مرسلة للسحب', 'مكتملة'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('تحديث بيانات التداول'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: currentStatus,
                decoration: const InputDecoration(labelText: 'حالة البطاقة'),
                items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => currentStatus = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: spentController,
                decoration: const InputDecoration(labelText: 'المبلغ المسحوب (\$)', prefixIcon: Icon(Ionicons.cash_outline)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Text(
                'المتبقي: \$${(card.limitUSD - (double.tryParse(spentController.text) ?? 0)).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                final updated = BankCard(
                  id: card.id,
                  cardNumber: card.cardNumber,
                  holderName: card.holderName,
                  phoneNumber: card.phoneNumber,
                  nationalId: card.nationalId,
                  bankName: card.bankName,
                  referenceCode: card.referenceCode,
                  isReserved: card.isReserved,
                  isDeposited: card.isDeposited,
                  limitUSD: card.limitUSD,
                  spentUSD: double.tryParse(spentController.text) ?? 0.0,
                  status: currentStatus,
                  treasuryId: card.treasuryId,
                  createdAt: card.createdAt,
                );
                provider.updateCard(updated);
                Navigator.pop(context);
              },
              child: const Text('حفظ التغييرات'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositConfirmation(BuildContext context, BankCard card) {
    final provider = context.read<AppProvider>();
    int? selectedTreasuryId;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('إيداع القيمة المقابلة (بالدينار)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Card(
                color: Colors.amberAccent,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'تنبيه: سيتم خصم هذا المبلغ من الخزينة لتغطية شحن البطاقة بالدولار.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'اختر الخزينة', prefixIcon: Icon(Ionicons.wallet_outline)),
                items: provider.treasuries.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                onChanged: (val) => setState(() => selectedTreasuryId = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController, 
                decoration: const InputDecoration(labelText: 'المبلغ بالدينار', prefixIcon: Icon(Ionicons.cash_outline)), 
                keyboardType: TextInputType.number
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (selectedTreasuryId == null || amountController.text.isEmpty) return;
                
                final amount = double.parse(amountController.text);
                provider.markCardAsDeposited(card.id!, selectedTreasuryId!, amount);
                
                // Automatically update status to 'تم الإيداع'
                final updated = BankCard(
                  id: card.id,
                  cardNumber: card.cardNumber,
                  holderName: card.holderName,
                  phoneNumber: card.phoneNumber,
                  nationalId: card.nationalId,
                  bankName: card.bankName,
                  referenceCode: card.referenceCode,
                  isReserved: true,
                  isDeposited: true,
                  limitUSD: card.limitUSD,
                  spentUSD: card.spentUSD,
                  status: 'تم الإيداع',
                  treasuryId: selectedTreasuryId,
                  createdAt: card.createdAt,
                );
                provider.updateCard(updated);
                
                Navigator.pop(context);
              },
              child: const Text('تأكيد الخصم والإيداع'),
            ),
          ],
        ),
      ),
    );
  }
}

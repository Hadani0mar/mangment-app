import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Import the operation screens
import 'operations/deposit_operation.dart';
import 'operations/withdraw_operation.dart';
import 'operations/transfer_operation.dart';
import 'operations/exchange_operation.dart';
import 'operations/purchase_operation.dart';

class OperationsHubScreen extends StatelessWidget {
  const OperationsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'العمليات المتاحة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 8),
            Text(
              'اختر نوع العملية التي ترغب في تنفيذها الآن',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 32),
            
            _buildActionItem(
              context,
              'إيداع رصيد نقدي',
              'إضافة أموال من مصدر خارجي إلى إحدى الخزائن',
              Ionicons.add_circle,
              Colors.green,
              const DepositOperationScreen(),
            ),
            _buildActionItem(
              context,
              'سحب رصيد نقدي',
              'تسجيل مبالغ مسحوبة أو مصروفات من الخزينة',
              Ionicons.remove_circle,
              Colors.red,
              const WithdrawOperationScreen(),
            ),
            _buildActionItem(
              context,
              'تحويل بين الخزائن',
              'نقل الأرصدة داخلياً بين الخزائن المتاحة',
              Ionicons.swap_horizontal,
              Colors.blue,
              const TransferOperationScreen(),
            ),
            _buildActionItem(
              context,
              'صرف عملات يدوية',
              'تبديل مبالغ بين خزائن بعملات مختلفة مع حاسبة',
              Ionicons.repeat,
              Colors.orange,
              const ExchangeOperationScreen(),
            ),
            _buildActionItem(
              context,
              'شراء عملة دولار (\$)',
              'عملية شراء دولار مخصصة بخصم من رصيد الدينار',
              Ionicons.cart,
              Colors.deepPurple,
              const PurchaseOperationScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget screen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Ionicons.chevron_forward, color: Colors.grey[300], size: 18),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/treasury.dart';
import '../models/transaction.dart';
import '../widgets/balance_card.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final treasuries = provider.treasuries;
    final transactions = provider.transactions.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Stats Summary
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'إجمالي الخزائن', 
                    treasuries.length.toString(), 
                    Icons.account_balance_wallet_rounded, 
                    const Color(0xFF6366F1)
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    'عمليات اليوم', 
                    _getTodayCount(provider.transactions).toString(), 
                    Icons.speed_rounded, 
                    const Color(0xFF22D3EE)
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    'مخصصات البطاقات', 
                    '\$${provider.cards.fold(0.0, (sum, item) => sum + item.limitUSD).toStringAsFixed(0)}', 
                    Icons.public_rounded, 
                    const Color(0xFFF59E0B)
                  ),
                ),
              ],
            ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
            
            const SizedBox(height: 32),
            
            // Middle Section: Distribution Chart & Recent Activity
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart section
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 350,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'توزيع الأرصدة',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 20),
                        Expanded(child: _buildPieChart(treasuries)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Recent activity section
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 350,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'أحدث العمليات',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            TextButton(onPressed: () {}, child: const Text('المزيد')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: transactions.isEmpty 
                            ? const Center(child: Text('لا توجد سجلات'))
                            : ListView.separated(
                                itemCount: transactions.length,
                                separatorBuilder: (_, __) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                itemBuilder: (context, index) => _buildTransactionItem(context, transactions[index]),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().slideY(begin: 0.2, delay: 200.ms, duration: 400.ms).fadeIn(),
            
            const SizedBox(height: 32),
            
            // Bottom Section: Treasury Grid
            const Text(
              'الأرصدة الحالية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            if (treasuries.isEmpty)
              _buildEmptyState(context)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.8,
                ),
                itemCount: treasuries.length,
                itemBuilder: (context, index) {
                  return BalanceCard(treasury: treasuries[index]).animate().scale(delay: (index * 50).ms);
                },
              ),
          ],
        ),
      ),
    );
  }

  int _getTodayCount(List<TransactionRecord> txs) {
    final now = DateTime.now();
    return txs.where((t) => t.date.day == now.day && t.date.month == now.month && t.date.year == now.year).length;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<Treasury> treasuries) {
    if (treasuries.isEmpty) return const Center(child: Text('لا توجد بيانات للرسم'));
    
    final colors = [
      const Color(0xFF6366F1), 
      const Color(0xFF22D3EE), 
      const Color(0xFFF59E0B), 
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
    ];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: treasuries.asMap().entries.map((entry) {
                final isTouched = false; // Add interaction state if needed
                return PieChartSectionData(
                  color: colors[entry.key % colors.length],
                  value: entry.value.balance,
                  title: '${(entry.value.balance).toStringAsFixed(0)}',
                  radius: isTouched ? 60 : 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  showTitle: entry.value.balance > 0,
                );
              }).toList(),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: treasuries.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[entry.key % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text('لا توجد بيانات حالية، أضف خزينة للبدء'),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionRecord tx) {
    Color statusColor = tx.type == TransactionType.deposit ? const Color(0xFF10B981) : 
                       tx.type == TransactionType.withdraw ? const Color(0xFFEF4444) : const Color(0xFF6366F1);
    
    IconData icon = tx.type == TransactionType.deposit ? Icons.south_west_rounded : 
                    tx.type == TransactionType.withdraw ? Icons.north_east_rounded : Icons.swap_horiz_rounded;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: statusColor, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx.note ?? _getTypeLabel(tx.type),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(tx.date),
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          '${tx.amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: statusColor),
        ),
      ],
    );
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit: return 'إيداع';
      case TransactionType.withdraw: return 'سحب';
      case TransactionType.transfer: return 'تحويل';
      case TransactionType.exchange: return 'صرافة';
      default: return '';
    }
  }
}

import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'treasuries_screen.dart';
import 'transactions_screen.dart';
import 'cards_screen.dart';
import 'settings_screen.dart';
import 'operations_hub_screen.dart';
import 'package:ionicons/ionicons.dart';

import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TreasuriesScreen(),
    const OperationsHubScreen(),
    const TransactionsScreen(),
    const CardsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          if (isWideScreen)
            Container(
              width: 280,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(5, 0)),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Logo / App Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'FINANCE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                  const SizedBox(height: 50),
                  _buildSidebarItem(0, Icons.grid_view_rounded, 'لوحة التحكم'),
                  _buildSidebarItem(1, Icons.account_balance_wallet_rounded, 'الخزائن'),
                  _buildSidebarItem(2, Icons.flash_on_rounded, 'العمليات الجديدة'),
                  _buildSidebarItem(3, Icons.swap_horizontal_circle_rounded, 'سجل العمليات'),
                  _buildSidebarItem(4, Icons.credit_card_rounded, 'البطاقات البنكية'),
                  const Spacer(),
                  _buildSidebarItem(5, Icons.settings_rounded, 'الإعدادات'),
                  const SizedBox(height: 12),
                  _buildSidebarAction(Ionicons.help_buoy_outline, 'دليل التعليمات', () => _showInstructionsDialog(context)),
                  const SizedBox(height: 20),
                  // App Version Info
                  Text(
                    'الإصدار 1.2.0',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, isWideScreen),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWideScreen
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: const Color(0xFF6366F1),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 20,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'الخزائن'),
                BottomNavigationBarItem(icon: Icon(Icons.flash_on_rounded), label: 'العمليات'),
                BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'السجل'),
                BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded), label: 'البطاقات'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'الإعدادات'),
              ],
            )
          : null,
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5), 
              size: 24
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05), duration: 200.ms),
    );
  }

  Widget _buildSidebarAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.5), size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DefaultTabController(
        length: 3,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('دليل الاستخدام المطور', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              children: [
                const TabBar(
                  labelColor: Color(0xFF4F46E5),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF4F46E5),
                  tabs: [
                    Tab(text: 'الخزائن'),
                    Tab(text: 'العمليات'),
                    Tab(text: 'البطاقات'),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildHelpContent(
                        'إدارة الخزائن',
                        'الخزائن هي الأوعية المالية الرئيسية في النظام. يمكنك إنشاء خزنة لكل عملة أو لكل غرض (خزنة رئيسية، محل، مصروفات شخصية).\n\n• أهمية الخزنة: تتبع الرصيد الفعلي المتاح.\n• التحويلات: يمكنك نقل الأموال بين الخزائن بسهولة.',
                        Ionicons.wallet_outline,
                      ),
                      _buildHelpContent(
                        'إدارة العمليات',
                        'هذا قسم يسجل حركات الأموال (إيداع، سحب، تحويل).\n\n• الإيداع: زيادة رصيد الخزنة.\n• السحب: تسجيل المصروفات.\n• التحويل: الربط بين خزنتين.\n• التتبع: يمكنك البحث عن أي عملية سابقة بالتاريخ والنوع.',
                        Ionicons.swap_horizontal_outline,
                      ),
                      _buildHelpContent(
                        'إدارة البطاقات',
                        'البطاقات هي بطاقات الدفع أو الفيزا المرتبطة بخزنة معينة.\n\n• الربط: كل بطاقة تسحب من رصيد خزنة محددة.\n• الاستخدام: لتسهيل إدارة البطاقات البنكية ومعرفة رصيد كل منها بشكل منفصل داخل الخزنة الواحدة.',
                        Ionicons.card_outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('فهمت ذلك')),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpContent(String title, String description, IconData icon) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Icon(icon, size: 50, color: const Color(0xFF4F46E5)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isWide) {
    final titles = ['نظرة عامة', 'إدارة الخزائن', 'العمليات الجديدة', 'سجل العمليات والقيد', 'البطاقات', 'الإعدادات'];
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titles[_selectedIndex],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
          Row(
            children: [
              _buildHeaderIcon(Icons.search_rounded),
              const SizedBox(width: 12),
              _buildHeaderIcon(Icons.notifications_none_rounded),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFF1F5F9),
                  child: Icon(Icons.person_rounded, color: Color(0xFF6366F1), size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF64748B), size: 20),
    );
  }
}

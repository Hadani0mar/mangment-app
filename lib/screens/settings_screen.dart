import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/database_helper.dart';
import '../services/license_service.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'محرك البيانات والنسخ الاحتياطي',
              [
                _buildSettingTile(
                  context,
                  'إنشاء نسخة احتياطية',
                  'حفظ نسخة من بياناتك في مجلد التحميلات الخاص بك',
                  Ionicons.cloud_upload_outline,
                  const Color(0xFF6366F1),
                  () => _createBackup(context),
                ),
                const SizedBox(height: 16),
                _buildSettingTile(
                  context,
                  'استعادة نسخة احتياطية',
                  'استبدال البيانات الحالية بملف نسخة احتياطية سابق',
                  Ionicons.cloud_download_outline,
                  const Color(0xFFF59E0B),
                  () => _restoreBackup(context),
                ),
                const SizedBox(height: 16),
                _buildSettingTile(
                  context,
                  'تفريغ قاعدة البيانات',
                  'حذف كافة البيانات (الخزائن، العمليات، البطاقات) بشكل نهائي',
                  Ionicons.trash_outline,
                  const Color(0xFFEF4444),
                  () => _clearData(context),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSection(
              context,
              'الترخيص والصلاحية',
              [
                Builder(
                  builder: (ctx) {
                    final license = ctx.watch<LicenseService>();
                    final expDate = license.expirationDate;
                    final formattedDate = expDate != null ? DateFormat('yyyy-MM-dd').format(expDate) : 'غير متوفر';
                    
                    final subtitle = license.isLifetime 
                      ? 'صلاحية مفتوحة (مدى الحياة)'
                      : 'صالح حتى $formattedDate (باقي ${license.daysLeft} يوم)';

                    return _buildSettingTile(
                      context,
                      'حالة الاشتراك',
                      subtitle,
                      Ionicons.shield_checkmark_outline,
                      Colors.green,
                      null,
                    );
                  }
                ),
                const SizedBox(height: 16),
                _buildSettingTile(
                  context,
                  'تسجيل الخروج (قفل النظام)',
                  'قفل الشاشة والعودة إلى واجهة التفعيل',
                  Ionicons.log_out_outline,
                  const Color(0xFFEF4444),
                  () {
                    context.read<LicenseService>().logout();
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSection(
              context,
              'معلومات النظام',
              [
                _buildSettingTile(
                  context,
                  'نظام الخزينة والبطاقات المالية',
                  'الإصدار 1.2.5 - تم التحديث بنجاح',
                  Ionicons.information_circle_outline,
                  const Color(0xFF64748B),
                  null,
                ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
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
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Ionicons.chevron_back_outline, color: Color(0xFF94A3B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'financial_system.db');
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        final backupFolder = await getDownloadsDirectory() ?? dbFolder;
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
        final backupPath = p.join(backupFolder.path, 'backup_financial_$timestamp.db');
        
        await dbFile.copy(backupPath);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء النسخة بنجاح في: $backupPath'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
       if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في النسخ: $e'), backgroundColor: Colors.red),
        );
       }
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('تأكيد الاستعادة'),
            content: const Text('تحذير: هذه العملية ستحذف كافة البيانات الحالية وتستبدلها بالنسخة المختارة. هل تريد الاستمرار؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx, true), 
                child: const Text('نعم، استعادة')
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final backupFile = File(result.files.single.path!);
          final dbFolder = await getApplicationDocumentsDirectory();
          final dbPath = p.join(dbFolder.path, 'financial_system.db');

          await DatabaseHelper.instance.closeDatabase();
          await backupFile.copy(dbPath);

          if (context.mounted) {
            await context.read<AppProvider>().init();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تمت استعادة البيانات بنجاح'), backgroundColor: Colors.green),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاستعادة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _clearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('تأكيد مسح البيانات'),
        content: const Text('هل أنت متأكد من رغبتك في مسح كافة البيانات؟ لا يمكن التراجع عن هذه العملية.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('مسح نهائي')
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AppProvider>().clearAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تفريغ قاعدة البيانات بنجاح'), backgroundColor: Colors.red),
      );
    }
  }
}

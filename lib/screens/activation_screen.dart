import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/license_service.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (license.showStartTrialOption) ...[
                  const Icon(Ionicons.cube_outline, size: 80, color: Colors.blueAccent)
                      .animate().scale(delay: 200.ms),
                  const SizedBox(height: 24),
                  const Text(
                    'مرحباً بك في النظام',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'نظام الخزينة والبطاقات المالي.\nيمكنك البدء بفترة تجريبية مجانية لمدة 3 أيام للتعرف على كفاءة النظام، أو إدخال رمز تفعيل إذا كان لديك واحد.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.5, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              await context.read<LicenseService>().startTrial();
                              setState(() => _isLoading = false);
                            },
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('ابدأ الفترة التجريبية (3 أيام)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('أو', style: TextStyle(color: Colors.grey))),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  const Icon(Ionicons.alert_circle, size: 80, color: Colors.orange)
                      .animate().shake(delay: 500.ms),
                  const SizedBox(height: 24),
                  const Text(
                    'انتهت الفترة التجريبية',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'لقد انتهت فترة استخدام نسختك التجريبية بنجاح.\nيرجى التواصل مع الدعم الفني للحصول على رمز تفعيل ومواصلة استخدام النظام.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.5, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 32),
                ],
                TextField(
                  controller: _codeController,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'أدخل رمز التفعيل هنا',
                    hintStyle: const TextStyle(letterSpacing: 0, fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                const SizedBox(height: 24),
                
                if (license.errorMessage != null && license.errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      license.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_codeController.text.trim().isEmpty) return;
                            
                            setState(() => _isLoading = true);
                            await context.read<LicenseService>().activateCode(_codeController.text.trim());
                            setState(() => _isLoading = false);
                          },
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('تفعيل النظام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        ),
      ),
    );
  }
}

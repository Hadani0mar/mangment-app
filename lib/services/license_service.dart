import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class LicenseService extends ChangeNotifier {
  bool isInitializing = true;
  bool isAuthorized = false;
  bool showStartTrialOption = false;
  String? errorMessage;
  DateTime? expirationDate;
  int daysLeft = 0;
  bool get isLifetime => daysLeft > 3650; // More than 10 years is considered lifetime

  final SupabaseClient _supabase = Supabase.instance.client;

  LicenseService() {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = await _getDeviceId();
      
      try {
        // Try online check
        final response = await _supabase.from('devices').select().eq('device_id', deviceId).maybeSingle();
        
        if (response == null) {
          // Device doesn't exist on server (never registered, or was deleted).
          // We MUST ignore old local preferences and show the Start Trial screen again.
          await prefs.remove('expiration_date');
          
          showStartTrialOption = true;
          isAuthorized = false;
          isInitializing = false;
          notifyListeners();
          return;
        }

        final dynamic deviceData = response;
        final expirationString = deviceData['expiration_date'] as String;
        expirationDate = DateTime.parse(expirationString);

        // Save locally for offline use overrides old cache
        await prefs.setString('expiration_date', expirationString);

      } catch (e) {
        // Offline or connection error, fallback to local storage
        final localExpiration = prefs.getString('expiration_date');
        if (localExpiration != null) {
          expirationDate = DateTime.parse(localExpiration);
        } else {
          // No local data, assume expired or cannot verify
          throw Exception('يتطلب الاتصال بالانترنت في أول مرة لتفعيل النظام.');
        }
      }

      if (expirationDate != null) {
        final now = DateTime.now();
        // Compare dates rather than just diff in days for accuracy
        if (expirationDate!.isAfter(now) || expirationDate!.isAtSameMomentAs(now)) {
          isAuthorized = true;
          daysLeft = expirationDate!.difference(now).inDays;
          if (daysLeft < 0) daysLeft = 0; // fallback if hours left
        } else {
          isAuthorized = false;
          daysLeft = 0;
        }
      } else {
        isAuthorized = false;
      }

    } catch (e) {
      isAuthorized = false;
      errorMessage = e.toString();
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> startTrial() async {
    try {
      final deviceId = await _getDeviceId();
      final deviceData = await _supabase.from('devices').insert({
        'device_id': deviceId,
      }).select().single();

      final expirationString = deviceData['expiration_date'] as String;
      expirationDate = DateTime.parse(expirationString);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('expiration_date', expirationString);

      showStartTrialOption = false;
      
      final now = DateTime.now();
      final diff = expirationDate!.difference(now).inDays;
      if (diff >= 0) {
        isAuthorized = true;
        daysLeft = diff;
      }
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء الاتصال بالخادم. يرجى المحاولة لاحقاً.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateCode(String code) async {
    try {
      final deviceId = await _getDeviceId();
      final rawRes = await _supabase.rpc('activate_device', params: {
        'p_device_id': deviceId,
        'p_code': code,
      });

      final Map<String, dynamic> res = Map<String, dynamic>.from(rawRes);

      if (res['success'] == true) {
        // Activation successful
        final newExpStr = res['new_expiration_date'] as String;
        expirationDate = DateTime.parse(newExpStr);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('expiration_date', newExpStr);
        
        isAuthorized = true;
        showStartTrialOption = false;
        daysLeft = expirationDate!.difference(DateTime.now()).inDays;
        errorMessage = null;
        notifyListeners();
        return true;
      } else {
        errorMessage = res['message']?.toString() ?? 'الكود غير صحيح';
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء الاتصال. ربما الكود خاطئ أو لا يوجد انترنت.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    // This will lock the app and return to the activation screen
    // Note: If the user restarts the app, the system will auto-login 
    // again if the device license is still active on the server.
    isAuthorized = false;
    notifyListeners();
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isWindows) {
      final winInfo = await deviceInfo.windowsInfo;
      return winInfo.deviceId;
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios_id';
    } else {
      return 'unknown_device_id';
    }
  }
}

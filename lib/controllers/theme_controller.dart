import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;
  final RxBool soundEnabled = true.obs;
  final RxBool vibrationEnabled = true.obs;
  final RxBool autoSave = true.obs;
  final RxBool showTimer = true.obs;
  final RxBool highlightSimilar = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    Map<String, dynamic> settings = await StorageService.loadSettings();
    
    isDarkMode.value = settings['isDarkMode'] ?? false;
    soundEnabled.value = settings['soundEnabled'] ?? true;
    vibrationEnabled.value = settings['vibrationEnabled'] ?? true;
    autoSave.value = settings['autoSave'] ?? true;
    showTimer.value = settings['showTimer'] ?? true;
    highlightSimilar.value = settings['highlightSimilar'] ?? true;
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    await _saveSettings();
  }

  Future<void> toggleSound() async {
    soundEnabled.value = !soundEnabled.value;
    await _saveSettings();
  }

  Future<void> toggleVibration() async {
    vibrationEnabled.value = !vibrationEnabled.value;
    await _saveSettings();
  }

  Future<void> toggleAutoSave() async {
    autoSave.value = !autoSave.value;
    await _saveSettings();
  }

  Future<void> toggleTimer() async {
    showTimer.value = !showTimer.value;
    await _saveSettings();
  }

  Future<void> toggleHighlightSimilar() async {
    highlightSimilar.value = !highlightSimilar.value;
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings(
      isDarkMode: isDarkMode.value,
      soundEnabled: soundEnabled.value,
      vibrationEnabled: vibrationEnabled.value,
      autoSave: autoSave.value,
      showTimer: showTimer.value,
      highlightSimilar: highlightSimilar.value,
    );
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1F2937),
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF9FAFB),
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  // Custom Colors
  Color get primaryGradientStart => isDarkMode.value 
      ? const Color(0xFF6366F1) 
      : const Color(0xFF8B5CF6);
      
  Color get primaryGradientEnd => isDarkMode.value 
      ? const Color(0xFF8B5CF6) 
      : const Color(0xFF06B6D4);

  Color get cardBackground => isDarkMode.value 
      ? const Color(0xFF1F2937).withOpacity(0.8)
      : Colors.white.withOpacity(0.9);

  Color get cellBackground => isDarkMode.value 
      ? const Color(0xFF374151)
      : const Color(0xFFF9FAFB);

  Color get selectedCellBackground => isDarkMode.value 
      ? const Color(0xFF6366F1).withOpacity(0.3)
      : const Color(0xFF6366F1).withOpacity(0.2);

  Color get fixedCellBackground => isDarkMode.value 
      ? const Color(0xFF4B5563)
      : const Color(0xFFE5E7EB);

  Color get errorCellBackground => isDarkMode.value 
      ? const Color(0xFFEF4444).withOpacity(0.3)
      : const Color(0xFFEF4444).withOpacity(0.2);

  Color get highlightedCellBackground => isDarkMode.value 
      ? const Color(0xFF10B981).withOpacity(0.2)
      : const Color(0xFF10B981).withOpacity(0.1);

  Color get textPrimary => isDarkMode.value 
      ? const Color(0xFFF9FAFB)
      : const Color(0xFF1F2937);

  Color get textSecondary => isDarkMode.value 
      ? const Color(0xFF9CA3AF)
      : const Color(0xFF6B7280);

  Color get borderColor => isDarkMode.value 
      ? const Color(0xFF4B5563)
      : const Color(0xFFD1D5DB);

  Color get successColor => const Color(0xFF10B981);
  Color get warningColor => const Color(0xFFF59E0B);
  Color get errorColor => const Color(0xFFEF4444);
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeController.primaryGradientStart.withOpacity(0.1),
              themeController.primaryGradientEnd.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // App Info Card
                _buildAppInfoCard(themeController),
                
                const SizedBox(height: 20),
                
                // Settings List
                Expanded(
                  child: ListView(
                    children: [
                      _buildSettingsSection(
                        'Appearance',
                        [
                          _buildSettingsTile(
                            'Dark Mode',
                            'Switch between light and dark themes',
                            Icons.dark_mode,
                            themeController,
                            isSwitch: true,
                            switchValue: themeController.isDarkMode,
                            onSwitchChanged: (value) => themeController.toggleDarkMode(),
                          ),
                        ],
                        themeController,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildSettingsSection(
                        'Game Settings',
                        [
                          _buildSettingsTile(
                            'Sound Effects',
                            'Enable game sound effects',
                            Icons.volume_up,
                            themeController,
                            isSwitch: true,
                            switchValue: themeController.soundEnabled,
                            onSwitchChanged: (value) => themeController.toggleSound(),
                          ),
                          _buildSettingsTile(
                            'Vibration',
                            'Enable haptic feedback',
                            Icons.vibration,
                            themeController,
                            isSwitch: true,
                            switchValue: themeController.vibrationEnabled,
                            onSwitchChanged: (value) => themeController.toggleVibration(),
                          ),
                          _buildSettingsTile(
                            'Auto Save',
                            'Automatically save game progress',
                            Icons.save,
                            themeController,
                            isSwitch: true,
                            switchValue: themeController.autoSave,
                            onSwitchChanged: (value) => themeController.toggleAutoSave(),
                          ),
                          _buildSettingsTile(
                            'Show Timer',
                            'Display game timer',
                            Icons.timer,
                            themeController,
                            isSwitch: true,
                            switchValue: themeController.showTimer,
                            onSwitchChanged: (value) => themeController.toggleTimer(),
                          ),
                          _buildSettingsTile(
                            'Highlight Similar',
                            'Highlight cells with same number',
                            Icons.highlight,
                            themeController,
                            isSwitch: true,
                            switchValue: themeController.highlightSimilar,
                            onSwitchChanged: (value) => themeController.toggleHighlightSimilar(),
                          ),
                        ],
                        themeController,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildSettingsSection(
                        'About',
                        [
                          _buildSettingsTile(
                            'Rate App',
                            'Rate us on the app store',
                            Icons.star,
                            themeController,
                            onTap: () => _showRateDialog(themeController),
                          ),
                          _buildSettingsTile(
                            'Share App',
                            'Share with friends',
                            Icons.share,
                            themeController,
                            onTap: () => _showShareDialog(themeController),
                          ),
                          _buildSettingsTile(
                            'Privacy Policy',
                            'View our privacy policy',
                            Icons.privacy_tip,
                            themeController,
                            onTap: () => _showPrivacyDialog(themeController),
                          ),
                          _buildSettingsTile(
                            'Version',
                            '1.0.0',
                            Icons.info,
                            themeController,
                          ),
                        ],
                        themeController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeController.primaryGradientStart,
            themeController.primaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeController.primaryGradientStart.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.grid_3x3,
              size: 32,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sudoku Master',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Challenge Your Mind',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(
      begin: -0.5,
      duration: 600.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildSettingsSection(
    String title,
    List<Widget> children,
    ThemeController themeController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeController.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: themeController.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    ).animate().slideX(
      begin: 1,
      duration: 600.ms,
      curve: Curves.easeOutBack,
    ).fadeIn(duration: 400.ms);
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    ThemeController themeController, {
    bool isSwitch = false,
    RxBool? switchValue,
    Function(bool)? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return Obx(() => ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeController.primaryGradientStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: themeController.primaryGradientStart,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: themeController.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: themeController.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: isSwitch && switchValue != null
          ? Switch(
              value: switchValue.value,
              onChanged: onSwitchChanged,
              activeColor: themeController.primaryGradientStart,
            )
          : onTap != null
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: themeController.textSecondary,
                )
              : null,
      onTap: onTap,
    ));
  }

  void _showRateDialog(ThemeController themeController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: themeController.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Rate Sudoku Master',
          style: TextStyle(
            color: themeController.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enjoying the app? Please take a moment to rate us!',
              style: TextStyle(
                color: themeController.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => 
                Icon(
                  Icons.star,
                  color: themeController.warningColor,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Later',
              style: TextStyle(
                color: themeController.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Thank You!',
                'Redirecting to app store...',
                backgroundColor: themeController.successColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.primaryGradientStart,
            ),
            child: const Text(
              'Rate Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(ThemeController themeController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: themeController.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Share Sudoku Master',
          style: TextStyle(
            color: themeController.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Share this amazing Sudoku app with your friends and family!',
          style: TextStyle(
            color: themeController.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: themeController.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Sharing...',
                'Opening share options',
                backgroundColor: themeController.successColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.primaryGradientStart,
            ),
            child: const Text(
              'Share',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(ThemeController themeController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: themeController.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: themeController.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'We respect your privacy. This app stores game data locally on your device and does not collect or share personal information with third parties.\n\nGame statistics and preferences are saved locally and can be reset at any time from the settings.',
            style: TextStyle(
              color: themeController.textSecondary,
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.primaryGradientStart,
            ),
            child: const Text(
              'Got it',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/theme_controller.dart';
import 'controllers/game_controller.dart';
import 'services/storage_service.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/game_screen.dart';
import 'views/screens/statistics_screen.dart';
import 'views/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SudokuMasterApp());
}

class SudokuMasterApp extends StatelessWidget {
  const SudokuMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final ThemeController themeController = Get.put(ThemeController());
    
    return Obx(() => GetMaterialApp(
      title: 'Sudoku Master',
      debugShowCheckedModeBanner: false,
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: themeController.isDarkMode.value 
          ? ThemeMode.dark 
          : ThemeMode.light,
      
      // Routes
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/game',
          page: () => const GameScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/statistics',
          page: () => const StatisticsScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ],
      
      // Global bindings
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<GameController>(() => GameController());
      }),
      
      // Default transition
      defaultTransition: Transition.cupertino,
      
      // Locale settings
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    ));
  }
}

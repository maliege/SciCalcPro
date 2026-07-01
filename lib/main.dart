import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/calculator_screen.dart';
import 'screens/astronomy_screen.dart';
import 'screens/electronics_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final themeController = await ThemeController.load();
  runApp(SciCalcProApp(themeController: themeController));
}

class SciCalcProApp extends StatelessWidget {
  final ThemeController themeController;
  const SciCalcProApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ThemeControllerScope(
      controller: themeController,
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'SciCalc Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeController.mode,
            home: const _AppShell(),
          );
        },
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();
  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _idx = 0;

  static const _screens = [
    CalculatorScreen(),
    AstronomyScreen(),
    ElectronicsScreen(),
    ConverterScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: colors.headerBg,
        indicatorColor: const Color(0xFF4FC3F7).withOpacity(0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate, color: Color(0xFF4FC3F7)),
            label: 'Hesap Makinesi',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: Color(0xFF9C6FD6)),
            label: 'Astronomi',
          ),
          NavigationDestination(
            icon: Icon(Icons.electrical_services_outlined),
            selectedIcon: Icon(Icons.electrical_services, color: Color(0xFF66BB6A)),
            label: 'Elektronik',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz, color: Color(0xFF4DB6AC)),
            label: 'Dönüştürücü',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFF4FC3F7)),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}

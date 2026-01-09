import 'package:flutter/material.dart';
import 'package:wmcdbi_petclinic_frontend/pages/owners_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wähle eine Desktop-orientierte Farbpalette (kann auf Wunsch angepasst werden)
    final primaryColor = const Color(0xFF116E57); // dunkelgrün-emerald
    final secondaryColor = const Color(0xFF8ABF9A); // helles grün
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);

    return MaterialApp(
      title: 'Spring Petclinic - Flutter',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.grey[900]),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[900]),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 15, color: Colors.grey[800]),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]),
          bodySmall: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  static const _navItems = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.pets), label: 'Owners'),
    NavigationDestination(icon: Icon(Icons.local_hospital), label: 'Pets/Visits'),
    NavigationDestination(icon: Icon(Icons.group), label: 'Vets'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const OwnersPage();
      default:
        return Center(
          child: Text('Seite: ${_navItems[_selectedIndex].label} (noch nicht implementiert)'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        // Logo-ähnliches Icon + Title, Desktop-Layout
        title: Row(
          children: [
            Icon(Icons.pets, size: 28, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: 12),
            Text('Spring Petclinic', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
          ],
        ),
        elevation: 2,
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.pets), label: Text('Owners')),
                NavigationRailDestination(icon: Icon(Icons.local_hospital), label: Text('Pets')),
                NavigationRailDestination(icon: Icon(Icons.group), label: Text('Vets')),
                NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
              ],
            )
          else
            const SizedBox.shrink(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: _navItems,
            ),
    );
  }
}

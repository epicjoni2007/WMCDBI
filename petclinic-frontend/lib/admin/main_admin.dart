import 'package:flutter/material.dart';
import '../pages/owners_page.dart';
import '../pages/pets_page.dart';
import '../pages/visits_page.dart';
import '../pages/vets_page.dart';
import '../pages/settings_page.dart';
import '../pages/dashboard_page.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF116E57);
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);
    return MaterialApp(
      title: 'Petclinic - Admin',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: const AdminShell(),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const OwnersPage();
      case 2:
        return const PetsPage();
      case 3:
        return const VisitsPage();
      case 4:
        return const VetsPage();
      case 5:
        return const SettingsPage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Petclinic')),
      body: Row(children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
            NavigationRailDestination(icon: Icon(Icons.pets), label: Text('Owners')),
            NavigationRailDestination(icon: Icon(Icons.pets), label: Text('Pets')),
            NavigationRailDestination(icon: Icon(Icons.event), label: Text('Termine')),
            NavigationRailDestination(icon: Icon(Icons.group), label: Text('Vets')),
            NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
          ],
        ),
        Expanded(child: _buildBody())
      ]),
    );
  }
}

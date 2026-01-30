import 'package:flutter/material.dart';
import 'package:wmcdbi_petclinic_frontend/pages/owners_page.dart';
import 'package:wmcdbi_petclinic_frontend/pages/dashboard_page.dart';
import 'package:wmcdbi_petclinic_frontend/pages/pets_page.dart';
import 'package:wmcdbi_petclinic_frontend/pages/vets_page.dart';
import 'package:wmcdbi_petclinic_frontend/pages/settings_page.dart';
import 'package:wmcdbi_petclinic_frontend/pages/pets_visits_page.dart';
import 'package:wmcdbi_petclinic_frontend/pages/visits_page.dart';
import 'package:wmcdbi_petclinic_frontend/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spring Petclinic - Flutter',
      theme: appTheme(),
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
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  static const _navItems = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.pets), label: 'Owners'),
    NavigationDestination(icon: Icon(Icons.pets), label: 'Pets'),
    NavigationDestination(icon: Icon(Icons.event), label: 'Termine'),
    NavigationDestination(icon: Icon(Icons.group), label: 'Vets'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

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
        return Center(
          child: Text('Seite: ${_navItems[_selectedIndex].label} (noch nicht implementiert)'),
        );
    }
  }

  Widget _sideNavButton(IconData icon, int index, String tooltip) {
    final selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        // Compact logo left; search on wide screens; title for narrow
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 1,
        title: Row(
          children: [
            // compact logo box
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(4)),
              child: Icon(Icons.pets, size: 20, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(width: 12),
            if (isWide)
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Suchen (Name, Stadt, Tier)',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            else
              Text('Spring Petclinic', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        actions: [
          IconButton(onPressed: () => setState(() => _selectedIndex = 5), icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface)),
          IconButton(onPressed: () {/* TODO: profile */}, icon: Icon(Icons.account_circle, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
      body: Column(
        children: [
          if (isWide)
            // Top horizontal navigation
            Container(
              color: Theme.of(context).colorScheme.surface,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                // Logo
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 0),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                    child: Icon(Icons.pets, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                const SizedBox(width: 16),
                // Nav items
                for (var i = 0; i < _navItems.length; i++) ...[
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Builder(builder: (ctx) {
                      // extract IconData from the widget stored in NavigationDestination.icon
                      final widgetIcon = _navItems[i].icon;
                      IconData navIconData = Icons.circle;
                      if (widgetIcon is Icon) {
                        navIconData = widgetIcon.icon ?? Icons.circle;
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedIndex == i ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(children: [
                          Icon(navIconData, color: _selectedIndex == i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, size: 18),
                          const SizedBox(width: 8),
                          Text(_navItems[i].label!, style: TextStyle(color: _selectedIndex == i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface)),
                        ]),
                      );
                    }),
                  ),
                ],
                const Spacer(),
                // optional quick actions on the right of top nav
                IconButton(onPressed: () => setState(() => _selectedIndex = 5), icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(width: 8),
                IconButton(onPressed: () {/* profile */}, icon: Icon(Icons.account_circle, color: Theme.of(context).colorScheme.onSurface)),
              ]),
            ),
          // Main content
          Expanded(child: _buildBody()),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

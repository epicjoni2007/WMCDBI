import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'user_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _showState(BuildContext context) async {
    final owners = await ApiService.getOwners();
    final pets = await ApiService.getAllPets();
    final vets = await ApiService.getVets();
    final visits = await ApiService.getAllVisits();

    final content = StringBuffer();
    content.writeln('Owners:');
    for (final o in owners) content.writeln(' - ${o.id}: ${o.fullName}');
    content.writeln('\nPets:');
    for (final p in pets) content.writeln(' - ${p.id}: ${p.name} (owner ${p.ownerId})');
    content.writeln('\nVets:');
    for (final v in vets) content.writeln(' - ${v.id}: ${v.firstName} ${v.lastName}');
    content.writeln('\nVisits:');
    for (final v in visits) content.writeln(' - ${v.id}: pet=${v.petId} vet=${v.vetId} desc=${v.description}');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Internal State'),
        content: SingleChildScrollView(child: Text(content.toString())),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const Text('Einstellungen & Info (noch nicht implementiert)'),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(onPressed: () => _showState(context), icon: const Icon(Icons.bug_report), label: const Text('Show internal state')),
                  const SizedBox(width: 8),
                  FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserPage())), icon: const Icon(Icons.phone_iphone), label: const Text('Open User Page (demo)')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

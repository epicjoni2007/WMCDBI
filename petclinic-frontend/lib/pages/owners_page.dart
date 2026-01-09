import 'package:flutter/material.dart';

import '../models/owner.dart';
import '../services/mock_service.dart';
import '../widgets/owner_card.dart';

class OwnersPage extends StatefulWidget {
  const OwnersPage({super.key});

  @override
  State<OwnersPage> createState() => _OwnersPageState();
}

class _OwnersPageState extends State<OwnersPage> {
  late Future<List<Owner>> _futureOwners;
  List<Owner> _owners = [];
  String _filter = '';
  bool _loading = true;
  String? _error;
  Owner? _selected;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  void _loadOwners() {
    setState(() {
      _loading = true;
      _error = null;
      _selected = null;
    });

    _futureOwners = MockService.fetchOwners();
    _futureOwners.then((list) {
      setState(() {
        _owners = list;
        _loading = false;
      });
    }).catchError((e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    });
  }

  List<Owner> get _filteredOwners {
    if (_filter.isEmpty) return _owners;
    final q = _filter.toLowerCase();
    return _owners
        .where((o) =>
            o.firstName.toLowerCase().contains(q) ||
            o.lastName.toLowerCase().contains(q) ||
            o.city.toLowerCase().contains(q))
        .toList();
  }

  void _selectOwner(Owner owner) {
    setState(() => _selected = owner);
  }

  void _editOwner(Owner owner) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit ${owner.fullName} (noch nicht implementiert)')));
  }

  void _deleteOwner(Owner owner) {
    setState(() {
      _owners.removeWhere((o) => o.id == owner.id);
      if (_selected?.id == owner.id) _selected = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${owner.fullName} gelöscht')));
  }

  Widget _buildListPane() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Fehler: $_error'));

    final list = _filteredOwners;
    if (list.isEmpty) return const Center(child: Text('Keine Einträge gefunden'));

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final owner = list[i];
        return OwnerCard(
          owner: owner,
          onTap: () => _selectOwner(owner),
          onEdit: () => _editOwner(owner),
          onDelete: () => _deleteOwner(owner),
        );
      },
    );
  }

  Widget _buildDetailPane() {
    if (_selected == null) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text('Wähle einen Owner aus der Liste', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Details werden hier angezeigt', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      );
    }

    final o = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    child: Text(o.firstName.isNotEmpty ? o.firstName[0] : '?', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.fullName, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text('${o.address}, ${o.city}', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        Text(o.telephone, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  FilledButton.icon(onPressed: () => _editOwner(o), icon: const Icon(Icons.edit), label: const Text('Edit'))
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pets', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Noch keine Pet-Details implementiert', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 900;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Owners', style: Theme.of(context).textTheme.headlineLarge),
                ),
                FilledButton.icon(onPressed: _loadOwners, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
                const SizedBox(width: 12),
                FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New Owner (noch nicht implementiert)'))), icon: const Icon(Icons.add), label: const Text('New Owner'))
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.search), hintText: 'Search owners by name or city'),
                        onChanged: (v) => setState(() => _filter = v),
                      ),
                    ),
                    if (!isWide)
                      FilledButton.icon(onPressed: _loadOwners, icon: const Icon(Icons.refresh), label: const Text('Refresh'))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isWide
                  ? Row(
                      children: [
                        SizedBox(width: 420, child: _buildListPane()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDetailPane()),
                      ],
                    )
                  : _buildListPane(),
            ),
          ],
        ),
      );
    });
  }
}

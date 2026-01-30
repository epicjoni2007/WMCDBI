import 'package:flutter/material.dart';

import '../models/owner.dart';
import '../models/pet.dart';
import '../models/visit.dart';
import '../services/api_service.dart';
import '../widgets/owner_card.dart';
import '../widgets/pet_card.dart';
import 'owner_detail_page.dart';
import 'pet_form_page.dart';
import 'visit_form_page.dart';

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

  // detail data for wide layout
  List<Pet> _detailPets = [];
  List<Visit> _detailVisits = [];
  bool _detailLoading = false;

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
      _detailPets = [];
      _detailVisits = [];
    });

    _futureOwners = ApiService.getOwners();
    _futureOwners.then((list) {
      if (!mounted) return;
      setState(() {
        _owners = list;
        _loading = false;
      });
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    });
  }

  Future<void> _loadOwnerDetails(Owner owner) async {
    setState(() {
      _detailLoading = true;
      _detailPets = [];
      _detailVisits = [];
    });
    final pets = await ApiService.getPetsForOwner(owner.id);
    final visits = await ApiService.getVisitsForOwner(owner.id);
    if (!mounted) return;
    setState(() {
      _detailPets = pets;
      _detailVisits = visits;
      _detailLoading = false;
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

  void _selectOwner(Owner owner, {required bool isWide}) {
    if (isWide) {
      setState(() => _selected = owner);
      _loadOwnerDetails(owner);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => OwnerDetailPage(owner: owner)));
    }
  }

  Future<void> _showOwnerForm({Owner? owner}) async {
    final isNew = owner == null;
    final firstCtrl = TextEditingController(text: owner?.firstName ?? '');
    final lastCtrl = TextEditingController(text: owner?.lastName ?? '');
    final addrCtrl = TextEditingController(text: owner?.address ?? '');
    final cityCtrl = TextEditingController(text: owner?.city ?? '');
    final telCtrl = TextEditingController(text: owner?.telephone ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? 'New Owner' : 'Edit Owner'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const ValueKey('firstName'),
                  controller: firstCtrl,
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  key: const ValueKey('lastName'),
                  controller: lastCtrl,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  key: const ValueKey('address'),
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  key: const ValueKey('city'),
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextFormField(
                  key: const ValueKey('telephone'),
                  controller: telCtrl,
                  decoration: const InputDecoration(labelText: 'Telephone'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            key: const ValueKey('saveButton'),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newOwner = Owner(
                id: owner?.id ?? 0,
                firstName: firstCtrl.text.trim(),
                lastName: lastCtrl.text.trim(),
                address: addrCtrl.text.trim(),
                city: cityCtrl.text.trim(),
                telephone: telCtrl.text.trim(),
              );

              try {
                if (isNew) {
                  final added = await ApiService.createOwner(newOwner);
                  if (!mounted) return;
                  setState(() => _selected = added);
                } else {
                  final updated = await ApiService.updateOwner(newOwner);
                  if (!mounted) return;
                  setState(() => _selected = updated);
                }
                Navigator.of(ctx).pop(true);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      _loadOwners();
    }
  }

  void _editOwner(Owner owner) {
    _showOwnerForm(owner: owner);
  }

  void _deleteOwner(Owner owner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Owner'),
        content: Text('Delete ${owner.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ok = await ApiService.deleteOwner(owner.id);
      if (!mounted) return;
      if (ok) {
        setState(() {
          _owners.removeWhere((o) => o.id == owner.id);
          if (_selected?.id == owner.id) _selected = null;
          _detailPets = [];
          _detailVisits = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${owner.fullName} gelöscht')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Löschen fehlgeschlagen')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Widget _buildListPane() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Fehler: $_error'));

    final list = _filteredOwners;
    if (list.isEmpty) return const Center(child: Text('Keine Einträge gefunden'));

    // Wrap list in RefreshIndicator so mobile can pull-to-refresh; use AlwaysScrollable when empty
    return RefreshIndicator(
      onRefresh: () async {
        _loadOwners();
        // wait until load completes
        await _futureOwners;
      },
      child: list.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 40), Center(child: Text('Keine Einträge gefunden'))],
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final owner = list[i];
                final isWide = MediaQuery.of(context).size.width > 900;
                return OwnerCard(
                  owner: owner,
                  onTap: () => _selectOwner(owner, isWide: isWide),
                  onEdit: () => _editOwner(owner),
                  onDelete: () => _deleteOwner(owner),
                );
              },
            ),
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
    if (_detailLoading) return const Center(child: CircularProgressIndicator());
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
                    backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(31),
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
          // Pets header + add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pets', style: Theme.of(context).textTheme.titleMedium),
              FilledButton.icon(
                onPressed: () async {
                  final res = await Navigator.of(context).push<Pet>(
                    MaterialPageRoute(builder: (_) => PetFormPage(initialOwnerId: o.id)),
                  );
                  if (res != null) {
                    if (res.id == 0) {
                      await ApiService.createPet(res);
                    } else {
                      await ApiService.updatePet(res);
                    }
                    await _loadOwnerDetails(o);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Pet'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_detailPets.isEmpty)
            Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Text('No pets found'))),
          // List pets with edit action
          for (final p in _detailPets) ...[
            PetCard(
              pet: p,
              onEdit: () async {
                final res = await Navigator.of(context).push<Pet>(
                  MaterialPageRoute(builder: (_) => PetFormPage(pet: p, initialOwnerId: p.ownerId)),
                );
                if (res != null) {
                  if (res.id == 0) {
                    await ApiService.createPet(res);
                  } else {
                    await ApiService.updatePet(res);
                  }
                  await _loadOwnerDetails(o);
                  _loadOwners();
                }
              },
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Visits', style: Theme.of(context).textTheme.titleMedium),
              FilledButton.icon(onPressed: _addVisit, icon: const Icon(Icons.add), label: const Text('Add Visit')),
            ],
          ),
          const SizedBox(height: 8),
          if (_detailVisits.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Text('No visits found'))),
          ..._detailVisits.map((v) => Card(child: ListTile(title: Text(v.description), subtitle: Text(v.date.toLocal().toString())))),
        ],
      ),
    );
  }

  Future<void> _addVisit() async {
    if (_selected == null) return;
    if (_detailPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kein Pet vorhanden. Bitte zuerst ein Pet anlegen.')));
      return;
    }
    final vets = await ApiService.getVets();
    final res = await Navigator.of(context).push<Visit>(MaterialPageRoute(builder: (_) => VisitFormPage(pets: _detailPets, vets: vets)));
    if (res != null) {
      await ApiService.createVisit(res);
      await _loadOwnerDetails(_selected!);
    }
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
                if (isWide)
                  FilledButton.icon(onPressed: _loadOwners, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
                const SizedBox(width: 12),
                FilledButton.icon(key: const ValueKey('newOwnerButton'), onPressed: () => _showOwnerForm(), icon: const Icon(Icons.add), label: const Text('New Owner'))
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
                    // secondary refresh intentionally removed for mobile
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

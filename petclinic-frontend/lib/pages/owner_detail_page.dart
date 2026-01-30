import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/owner.dart';
import '../models/pet.dart';
import '../models/visit.dart';
import '../models/vet.dart';
import '../services/api_service.dart';
import '../widgets/pet_card.dart';
import 'pet_form_page.dart';
import 'visit_form_page.dart';

class OwnerDetailPage extends StatefulWidget {
  final Owner owner;

  const OwnerDetailPage({super.key, required this.owner});

  @override
  State<OwnerDetailPage> createState() => _OwnerDetailPageState();
}

class _OwnerDetailPageState extends State<OwnerDetailPage> {
  List<Pet> _pets = [];
  List<Visit> _visits = [];
  List<Vet> _vets = [];
  bool _loading = true;
  Map<int, String> _petNames = {};
  Map<int, String> _vetNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final pets = await ApiService.getPetsForOwner(widget.owner.id);
    final visits = await ApiService.getVisitsForOwner(widget.owner.id);
    final vets = await ApiService.getVets();
    if (!mounted) return;
    // Build lookup maps for quick rendering
    final petNames = <int, String>{};
    for (final p in pets) {
      petNames[p.id] = p.name;
    }
    final vetNames = <int, String>{};
    for (final v in vets) {
      vetNames[v.id] = '${v.firstName} ${v.lastName}';
    }

    setState(() {
      _pets = pets;
      _visits = visits;
      _vets = vets;
      _petNames = petNames;
      _vetNames = vetNames;
      _loading = false;
    });
  }

  Future<void> _addPet() async {
    final res = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(builder: (_) => PetFormPage(initialOwnerId: widget.owner.id)),
    );
    if (res != null) {
      if (res.id == 0) {
        final created = await ApiService.createPet(res);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tier erstellt: ${created.name}')));
      } else {
        final updated = await ApiService.updatePet(res);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tier aktualisiert: ${updated.name}')));
      }
      await _loadData();
    }
  }

  Future<void> _editPet(Pet pet) async {
    final res = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(builder: (_) => PetFormPage(pet: pet, initialOwnerId: pet.ownerId)),
    );
    if (res != null) {
      if (res.id == 0) {
        final created = await ApiService.createPet(res);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tier erstellt: ${created.name}')));
      } else {
        final updated = await ApiService.updatePet(res);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tier aktualisiert: ${updated.name}')));
      }
      await _loadData();
    }
  }

  Future<void> _addVisit() async {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kein Pet vorhanden. Bitte zuerst ein Pet anlegen.')));
      return;
    }
    final res = await Navigator.of(context).push<Visit>(
      MaterialPageRoute(builder: (_) => VisitFormPage(pets: _pets, vets: _vets)),
    );
    if (res != null) {
      final created = await ApiService.createVisit(res);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Termin erstellt: ${created.description}')));
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.owner.fullName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Contact', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.owner.address}, ${widget.owner.city}',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(widget.owner.telephone, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pets', style: Theme.of(context).textTheme.headlineSmall),
                      FilledButton.icon(onPressed: _addPet, icon: const Icon(Icons.add), label: const Text('Tier hinzufügen')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_pets.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Text('No pets found'))),
                  ..._pets.map((p) => PetCard(pet: p, onEdit: () => _editPet(p))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Termine', style: Theme.of(context).textTheme.headlineSmall),
                      FilledButton.icon(onPressed: _addVisit, icon: const Icon(Icons.add), label: const Text('Termin hinzufügen')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_visits.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Text('No visits found'))),
                  // Für jeden Visit: benutze Lookup-Maps für Tier- und Tierarztnamen
                  ..._visits.map((v) {
                    final petLabel = _petNames[v.petId] ?? 'Unbekanntes Tier';
                    final vetLabel = v.vetId == null ? 'Kein Tierarzt' : (_vetNames[v.vetId] ?? 'Unbekannter Tierarzt');
                    // Use a Column for subtitle and format date with intl
                    final fmt = DateFormat('dd.MM.yyyy HH:mm');
                    final dateStr = fmt.format(v.date.toLocal());
                    return Card(
                      child: ListTile(
                        title: Text(v.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Text('Tier: $petLabel • Tierarzt: $vetLabel', maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

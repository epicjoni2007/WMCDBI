import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/owner.dart';
import '../models/pet.dart';
import '../models/visit.dart';
import '../models/vet.dart';
import '../services/api_service.dart';
import '../widgets/pet_card.dart';
import 'visit_form_page.dart';
import 'pet_form_page.dart';

// Mobile User page (Demo) - shows owner's pets and appointments
class UserPage extends StatefulWidget {
  // demoOwnerId: optional; if null we pick first owner
  final int? demoOwnerId;
  const UserPage({super.key, this.demoOwnerId});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Owner? _owner;
  List<Pet> _pets = [];
  List<Visit> _visits = [];
  List<Vet> _vets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final owners = await ApiService.getOwners();
      if (owners.isEmpty) throw Exception('No owners available');
      final owner = widget.demoOwnerId == null
          ? owners.first
          : owners.firstWhere((o) => o.id == widget.demoOwnerId, orElse: () => owners.first);

      final pets = await ApiService.getPetsForOwner(owner.id);
      final visits = await ApiService.getVisitsForOwner(owner.id);
      final vets = await ApiService.getVets();

      if (!mounted) return;
      setState(() {
        _owner = owner;
        _pets = pets;
        _visits = visits;
        _vets = vets;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addVisitForOwner() async {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kein Tier vorhanden. Bitte erst ein Tier anlegen.')));
      return;
    }
    final res = await Navigator.of(context).push<Visit>(MaterialPageRoute(builder: (_) => VisitFormPage(pets: _pets, vets: _vets)));
    if (res != null) {
      await ApiService.createVisit(res);
      await _loadAll();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Termin erstellt')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text(_owner?.fullName ?? 'User')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Fehler: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Profil', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(_owner!.fullName, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            Text('${_owner!.address}, ${_owner!.city}'),
                            const SizedBox(height: 6),
                            Text(_owner!.telephone),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Meine Tiere', style: Theme.of(context).textTheme.titleMedium),
                        FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PetFormPage())), icon: const Icon(Icons.add), label: const Text('Neues Tier')),
                      ]),
                      const SizedBox(height: 8),
                      if (_pets.isEmpty)
                        Card(child: Padding(padding: const EdgeInsets.all(12), child: const Text('Keine Haustiere gefunden'))),
                      ..._pets.map((p) => PetCard(pet: p, onEdit: () async {
                            final res = await Navigator.of(context).push<Pet>(MaterialPageRoute(builder: (_) => PetFormPage(pet: p, initialOwnerId: p.ownerId)));
                            if (res != null) {
                              if (res.id == 0) {
                                await ApiService.createPet(res);
                              } else {
                                await ApiService.updatePet(res);
                              }
                              await _loadAll();
                            }
                          })),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Meine Termine', style: Theme.of(context).textTheme.titleMedium),
                        FilledButton.icon(onPressed: _addVisitForOwner, icon: const Icon(Icons.add), label: const Text('Neuer Termin')),
                      ]),
                      const SizedBox(height: 8),
                      if (_visits.isEmpty)
                        Card(child: Padding(padding: const EdgeInsets.all(12), child: const Text('Keine Termine gefunden'))),
                      ..._visits.map((v) => Card(
                            child: ListTile(
                              title: Text(v.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${dateFmt.format(v.date.toLocal())} • Pet #${v.petId}'),
                            ),
                          )),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
    );
  }
}

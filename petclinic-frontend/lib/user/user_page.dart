import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/owner.dart';
import '../models/pet.dart';
import '../models/visit.dart';
import '../models/vet.dart';
import '../services/api_service.dart';
import '../widgets/pet_card.dart';

// Read-only user page: no editing/creation from mobile app (login will enable actions later)

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
  int _selectedIndex = 0; // 0 = Pets, 1 = Appointments

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

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    // Build two-tab layout (Pets | Appointments)
    Widget petsTab() {
      return RefreshIndicator(
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
            Text('Meine Tiere', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_pets.isEmpty)
              Card(child: Padding(padding: const EdgeInsets.all(12), child: const Text('Keine Haustiere gefunden'))),
            // show pet cards (no edit on mobile)
            ..._pets.map((p) => PetCard(pet: p)),
            const SizedBox(height: 60),
          ],
        ),
      );
    }

    Widget visitsTab() {
      return RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Meine Termine', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_visits.isEmpty)
              Card(child: Padding(padding: const EdgeInsets.all(12), child: const Text('Keine Termine gefunden'))),
            ..._visits.map((v) {
              final pet = _pets.firstWhere((p) => p.id == v.petId, orElse: () => Pet(id: 0, name: 'Unbekannt', birthDate: DateTime(1970), type: '', ownerId: 0));
              final petLabel = pet.id == 0 ? 'Unbekannt' : pet.name;
              return Card(
                child: ListTile(
                  title: Text(v.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${dateFmt.format(v.date.toLocal())} • $petLabel'),
                ),
              );
            }),
            const SizedBox(height: 60),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_owner?.fullName ?? 'User')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Fehler: $_error'))
              : (_selectedIndex == 0 ? petsTab() : visitsTab()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Tiere'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Termine'),
        ],
      ),
    );
  }
}

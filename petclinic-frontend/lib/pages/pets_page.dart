import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/api_service.dart';
import '../widgets/pet_card.dart';
import 'pet_form_page.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  List<Pet> _pets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final pets = await ApiService.getAllPets();
      if (!mounted) return;
      setState(() {
        _pets = pets;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addPet() async {
    final res = await Navigator.of(context).push<Pet>(MaterialPageRoute(builder: (_) => const PetFormPage()));
    if (res != null) {
      if (res.id == 0) {
        await ApiService.createPet(res);
      } else {
        await ApiService.updatePet(res);
      }
      await _load();
    }
  }

  Future<void> _editPet(Pet pet) async {
    final res = await Navigator.of(context).push<Pet>(MaterialPageRoute(builder: (_) => PetFormPage(pet: pet)));
    if (res != null) {
      if (res.id == 0) {
        await ApiService.createPet(res);
      } else {
        await ApiService.updatePet(res);
      }
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Pets', style: Theme.of(context).textTheme.headlineLarge)),
              FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
              const SizedBox(width: 12),
              FilledButton.icon(onPressed: _addPet, icon: const Icon(Icons.add), label: const Text('New Pet')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Fehler: $_error'))
                    : _pets.isEmpty
                        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('No pets available'), const SizedBox(height: 12), FilledButton.icon(onPressed: _addPet, icon: const Icon(Icons.add), label: const Text('Add Pet'))]))
                        : ListView.builder(
                            itemCount: _pets.length,
                            itemBuilder: (context, i) => PetCard(pet: _pets[i], onEdit: () => _editPet(_pets[i])),
                          ),
          ),
        ],
      ),
    );
  }
}

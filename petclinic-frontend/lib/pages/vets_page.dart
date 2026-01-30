import 'package:flutter/material.dart';
import '../models/vet.dart';
import '../services/api_service.dart';
import 'vet_form_page.dart';

class VetsPage extends StatefulWidget {
  const VetsPage({super.key});

  @override
  State<VetsPage> createState() => _VetsPageState();
}

class _VetsPageState extends State<VetsPage> {
  List<Vet> _vets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final vets = await ApiService.getVets();
    setState(() {
      _vets = vets;
      _loading = false;
    });
  }

  Future<void> _addVet() async {
    final res = await Navigator.of(context).push<Vet>(MaterialPageRoute(builder: (_) => const VetFormPage()));
    if (res != null) {
      if (res.id == 0) {
        await ApiService.createVet(res);
      } else {
        await ApiService.updateVet(res);
      }
      await _load();
    }
  }

  Future<void> _editVet(Vet vet) async {
    final res = await Navigator.of(context).push<Vet>(MaterialPageRoute(builder: (_) => VetFormPage(vet: vet)));
    if (res != null) {
      if (res.id == 0) {
        await ApiService.createVet(res);
      } else {
        await ApiService.updateVet(res);
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
              Expanded(child: Text('Vets', style: Theme.of(context).textTheme.headlineLarge)),
              FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
              const SizedBox(width: 12),
              FilledButton.icon(onPressed: _addVet, icon: const Icon(Icons.add), label: const Text('New Vet')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _vets.length,
                    itemBuilder: (context, i) {
                      final v = _vets[i];
                      return Card(
                        child: ListTile(
                          title: Text('${v.firstName} ${v.lastName}'),
                          subtitle: Text(v.specialties.join(', ')),
                          trailing: IconButton(onPressed: () => _editVet(v), icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

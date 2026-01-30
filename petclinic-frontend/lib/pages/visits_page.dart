import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';
import '../services/api_service.dart';
import 'visit_form_page.dart';
import '../models/pet.dart';
import '../models/vet.dart';

class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  List<Visit> _visits = [];
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
      final visits = await ApiService.getAllVisits();
      if (!mounted) return;
      setState(() {
        _visits = visits;
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

  Future<void> _addVisit() async {
    final pets = await ApiService.getAllPets();
    final vets = await ApiService.getVets();
    final res = await Navigator.of(context).push<Visit>(MaterialPageRoute(builder: (_) => VisitFormPage(pets: pets, vets: vets)));
    if (res != null) {
      if (res.id == 0) {
        await ApiService.createVisit(res);
      } else {
        await ApiService.updateVisit(res);
      }
      await _load();
    }
  }

  Future<void> _editVisit(Visit visit) async {
    final pets = await ApiService.getAllPets();
    final vets = await ApiService.getVets();
    final res = await Navigator.of(context).push<Visit>(MaterialPageRoute(builder: (_) => VisitFormPage(pets: pets, vets: vets, visit: visit)));
    if (res != null) {
      if (res.id == 0) {
        await ApiService.createVisit(res);
      } else {
        await ApiService.updateVisit(res);
      }
      await _load();
    }
  }

  Future<void> _deleteVisit(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visit'),
        content: const Text('Delete this visit?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ApiService.deleteVisit(id);
    await _load();
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
              Expanded(child: Text('Termine', style: Theme.of(context).textTheme.headlineLarge)),
              const SizedBox(width: 12),
              FilledButton.icon(onPressed: _addVisit, icon: const Icon(Icons.add), label: const Text('Neuer Termin')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Fehler: $_error'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: _visits.isEmpty
                            // For empty state use a scrollable so pull-to-refresh works
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const SizedBox(height: 40), const Text('Keine Termine'), const SizedBox(height: 12), FilledButton.icon(onPressed: _addVisit, icon: const Icon(Icons.add), label: const Text('Termin hinzufügen'))]))
                                ],
                              )
                            : ListView.builder(
                                itemCount: _visits.length,
                                itemBuilder: (context, i) {
                                  final v = _visits[i];
                                  return FutureBuilder<List<dynamic>>(
                                    future: Future.wait([ApiService.getPetById(v.petId), ApiService.getVetById(v.vetId ?? -1)]),
                                    builder: (context, snap) {
                                      String petLabel = 'Pet #${v.petId}';
                                      String vetLabel = v.vetId == null ? 'No vet' : 'Vet #${v.vetId}';
                                      if (snap.hasData) {
                                        final results = snap.data!;
                                        final pet = results[0] as Pet?;
                                        final vet = results[1] as Vet?;
                                        if (pet != null) petLabel = pet.name;
                                        if (vet != null) vetLabel = '${vet.firstName} ${vet.lastName}';
                                      }
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
                                              Text('$petLabel • $vetLabel', maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                          isThreeLine: true,
                                          trailing: SizedBox(
                                            width: 96,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                IconButton(onPressed: () => _editVisit(v), icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary)),
                                                IconButton(onPressed: () => _deleteVisit(v.id), icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                       ),
           ),
         ],
       ),
     );
   }
 }

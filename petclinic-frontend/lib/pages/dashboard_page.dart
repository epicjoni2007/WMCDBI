import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  String? _error;
  List<Visit> _visitsForDate = [];
  int _ownersCount = 0;
  int _petsCount = 0;
  int _vetsCount = 0;
  int _totalVisits = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadStats();
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Load all data we need for dashboard statistics
      final owners = await ApiService.getOwners();
      final pets = await ApiService.getAllPets();
      final vets = await ApiService.getVets();
      final all = await ApiService.getAllVisits();

      // Store totals
      _ownersCount = owners.length;
      _petsCount = pets.length;
      _vetsCount = vets.length;
      _totalVisits = all.length;

      // Filter visits for selected date
      final s = _selectedDate;
      _visitsForDate = all.where((v) {
        final d = v.date.toLocal();
        return d.year == s.year && d.month == s.month && d.day == s.day;
      }).toList();
      if (!mounted) return;
      setState(() {
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
    final dateLabel = DateFormat('dd.MM.yyyy').format(_selectedDate);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Dashboard', style: Theme.of(context).textTheme.headlineLarge)),
          FilledButton.icon(onPressed: _pickDate, icon: const Icon(Icons.date_range), label: Text(dateLabel)),
          const SizedBox(width: 12),
          FilledButton.icon(onPressed: _loadStats, icon: const Icon(Icons.refresh), label: const Text('Aktualisieren')),
        ]),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(child: Text('Fehler: $_error'))
        else ...[
          // Summary stat cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard('Owners', _ownersCount, context),
              _buildStatCard('Pets', _petsCount, context),
              _buildStatCard('Vets', _vetsCount, context),
              _buildStatCard('Total Visits', _totalVisits, context),
              _buildStatCard('Visits on $dateLabel', _visitsForDate.length, context),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Statistiken für $dateLabel', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Anzahl Termine: ${_visitsForDate.length}', style: Theme.of(context).textTheme.headlineSmall),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _visitsForDate.isEmpty
                ? Center(child: Text('Keine Termine für $dateLabel'))
                : ListView.builder(
                    itemCount: _visitsForDate.length,
                    itemBuilder: (context, i) {
                      final v = _visitsForDate[i];
                      return FutureBuilder<List<dynamic>>(
                        future: Future.wait([ApiService.getPetById(v.petId), ApiService.getVetById(v.vetId ?? -1)]),
                        builder: (context, snap) {
                          String petLabel = 'Pet #${v.petId}';
                          String vetLabel = v.vetId == null ? 'Kein Tierarzt' : 'Vet #${v.vetId}';
                          if (snap.hasData) {
                            final pet = snap.data![0] as dynamic?;
                            final vet = snap.data![1] as dynamic?;
                            if (pet != null) petLabel = pet.name as String;
                            if (vet != null) vetLabel = '${vet.firstName} ${vet.lastName}' as String;
                          }
                          final timeStr = DateFormat('HH:mm').format(v.date.toLocal());
                          return Card(
                            child: ListTile(
                              title: Text(v.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('$timeStr • $petLabel • $vetLabel'),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ]
      ]),
    );
  }

  Widget _buildStatCard(String label, int value, BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('$value', style: Theme.of(context).textTheme.headlineSmall),
          ]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../models/pet.dart';
import '../models/vet.dart';

class VisitFormPage extends StatefulWidget {
  final List<Pet> pets;
  final List<Vet> vets;
  final Visit? visit;

  const VisitFormPage({super.key, required this.pets, required this.vets, this.visit});

  @override
  State<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends State<VisitFormPage> {
  Pet? _selectedPet;
  Vet? _selectedVet;
  DateTime _date = DateTime.now();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.pets.isNotEmpty) _selectedPet = widget.visit == null ? widget.pets.first : widget.pets.firstWhere((p) => p.id == widget.visit!.petId, orElse: () => widget.pets.first);
    if (widget.vets.isNotEmpty) _selectedVet = widget.visit == null ? widget.vets.first : widget.vets.firstWhere((v) => v.id == widget.visit!.vetId, orElse: () => widget.vets.first);
    if (widget.visit != null) {
      _date = widget.visit!.date;
      _descCtrl.text = widget.visit!.description;
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _selectedPet == null) return;
    final visit = Visit(id: widget.visit?.id ?? 0, petId: _selectedPet!.id, vetId: _selectedVet?.id, date: _date, description: _descCtrl.text.trim());
    Navigator.of(context).pop(visit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.visit == null ? 'New Visit' : 'Edit Visit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<Pet>(
                value: _selectedPet,
                items: widget.pets.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                onChanged: (v) => setState(() => _selectedPet = v),
                decoration: const InputDecoration(labelText: 'Pet'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Vet>(
                value: _selectedVet,
                items: widget.vets.map((v) => DropdownMenuItem(value: v, child: Text('${v.firstName} ${v.lastName}'))).toList(),
                onChanged: (v) => setState(() => _selectedVet = v),
                decoration: const InputDecoration(labelText: 'Vet'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(_date.toLocal().toIso8601String().split('T').first)),
                  FilledButton(onPressed: _pickDate, child: const Text('Pick date')),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _save, child: const Text('Save')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/owner.dart';
import '../services/api_service.dart';

class PetFormPage extends StatefulWidget {
  final Pet? pet;
  final int? initialOwnerId;

  const PetFormPage({super.key, this.pet, this.initialOwnerId});

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  late TextEditingController _nameCtrl;
  DateTime? _birthDate;
  String _type = 'dog';
  final _formKey = GlobalKey<FormState>();

  List<Owner> _owners = [];
  int? _selectedOwnerId;
  bool _loadingOwners = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.pet?.name ?? '');
    _birthDate = widget.pet?.birthDate;
    _type = widget.pet?.type ?? 'dog';
    _selectedOwnerId = widget.pet?.ownerId ?? widget.initialOwnerId;
    _loadOwners();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOwners() async {
    setState(() => _loadingOwners = true);
    final owners = await ApiService.getOwners();
    if (!mounted) return;
    setState(() {
      _owners = owners;
      // if selected owner id is null and owners exist, pick first
      _selectedOwnerId ??= owners.isNotEmpty ? owners.first.id : null;
      _loadingOwners = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _birthDate == null || _selectedOwnerId == null) return;
    final pet = Pet(
      id: widget.pet?.id ?? 0,
      name: _nameCtrl.text.trim(),
      birthDate: _birthDate!,
      type: _type,
      ownerId: _selectedOwnerId!,
    );
    print('[PetForm] saving pet id=${pet.id} name=${pet.name} owner=${pet.ownerId}');
    Navigator.of(context).pop(pet);
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime d) => d.toLocal().toIso8601String().split('T').first;
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet == null ? 'New Pet' : 'Edit Pet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_birthDate == null ? 'Birth date not set' : formatDate(_birthDate!)),
                  ),
                  FilledButton(onPressed: _pickDate, child: const Text('Pick date')),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'dog', child: Text('Dog')),
                  DropdownMenuItem(value: 'cat', child: Text('Cat')),
                  DropdownMenuItem(value: 'bird', child: Text('Bird')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'dog'),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 12),
              _loadingOwners
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                      value: _selectedOwnerId,
                      items: _owners.map((o) => DropdownMenuItem(value: o.id, child: Text(o.fullName))).toList(),
                      onChanged: (v) => setState(() => _selectedOwnerId = v),
                      decoration: const InputDecoration(labelText: 'Owner'),
                    ),
              const SizedBox(height: 20),
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

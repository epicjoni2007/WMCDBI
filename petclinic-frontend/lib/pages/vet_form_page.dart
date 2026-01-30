import 'package:flutter/material.dart';
import '../models/vet.dart';

class VetFormPage extends StatefulWidget {
  final Vet? vet;

  const VetFormPage({super.key, this.vet});

  @override
  State<VetFormPage> createState() => _VetFormPageState();
}

class _VetFormPageState extends State<VetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstCtrl;
  late TextEditingController _lastCtrl;
  late TextEditingController _specsCtrl;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(text: widget.vet?.firstName ?? '');
    _lastCtrl = TextEditingController(text: widget.vet?.lastName ?? '');
    _specsCtrl = TextEditingController(text: widget.vet?.specialties.join(', ') ?? '');
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _specsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final specialties = _specsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final vet = Vet(
      id: widget.vet?.id ?? 0,
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      specialties: specialties,
    );
    Navigator.of(context).pop(vet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vet == null ? 'New Vet' : 'Edit Vet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstCtrl,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastCtrl,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specsCtrl,
                decoration: const InputDecoration(labelText: 'Specialties (comma separated)'),
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

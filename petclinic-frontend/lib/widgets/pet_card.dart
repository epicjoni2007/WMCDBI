import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const PetCard({super.key, required this.pet, this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(pet.name.isNotEmpty ? pet.name[0] : '?'),
        ),
        title: Text(pet.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${pet.type} • ${pet.birthDate.toLocal().toIso8601String().split('T').first}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SizedBox(
          width: 48,
          child: IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}

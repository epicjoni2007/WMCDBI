import 'dart:io';
import 'package:wmcdbi_petclinic_frontend/services/api_service.dart';
import 'package:wmcdbi_petclinic_frontend/models/pet.dart';
import 'package:wmcdbi_petclinic_frontend/models/visit.dart';

Future<void> main() async {
  print('--- SMOKE API TEST ---');
  ApiService.useMock = true;

  final pet = await ApiService.createPet(Pet(id: 0, name: 'Testy', birthDate: DateTime(2020), type: 'dog', ownerId: 1));
  print('Created pet: ${pet.id} ${pet.name} owner=${pet.ownerId}');

  final updated = Pet(id: pet.id, name: 'Testy Updated', birthDate: pet.birthDate, type: pet.type, ownerId: pet.ownerId);
  final up = await ApiService.updatePet(updated);
  print('Updated pet: ${up.id} ${up.name} owner=${up.ownerId}');

  final visit = await ApiService.createVisit(Visit(id: 0, petId: pet.id, vetId: 1, date: DateTime.now(), description: 'Checkup'));
  print('Created visit: ${visit.id} pet=${visit.petId} vet=${visit.vetId}');

  final visitUp = Visit(id: visit.id, petId: visit.petId, vetId: visit.vetId, date: visit.date, description: 'Checkup - updated');
  final vup = await ApiService.updateVisit(visitUp);
  print('Updated visit: ${vup.id} desc=${vup.description}');

  exit(0);
}

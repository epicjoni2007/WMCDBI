import 'dart:async';

import 'package:wmcdbi_petclinic_frontend/models/pet.dart';
import 'package:wmcdbi_petclinic_frontend/models/vet.dart';
import 'package:wmcdbi_petclinic_frontend/models/visit.dart';
import 'package:wmcdbi_petclinic_frontend/models/owner.dart';
import 'mock_service.dart';

// Einfache ApiService-Implementierung, die aktuell Mock-Daten verwendet.
// Später kann `useMock = false` auf echte HTTP-Requests umgestellt werden.
class ApiService {
  static bool useMock = true;

  // --- Owners ---
  static Future<List<Owner>> getOwners() async {
    if (useMock) return MockService.fetchOwners();
    // TODO: echte HTTP-Implementierung
    return MockService.fetchOwners();
  }

  static Future<Owner> getOwner(int id) async {
    final list = await getOwners();
    return list.firstWhere((o) => o.id == id);
  }

  static Future<Owner> createOwner(Owner owner) async {
    if (useMock) {
      print('[ApiService] createOwner called: ${owner.firstName} ${owner.lastName}');
      return MockService.addOwner(owner);
    }
    print('[ApiService] createOwner (no-mock) called');
    return MockService.addOwner(owner);
  }

  static Future<Owner> updateOwner(Owner owner) async {
    if (useMock) {
      print('[ApiService] updateOwner called: id=${owner.id} ${owner.firstName} ${owner.lastName}');
      return MockService.updateOwner(owner);
    }
    print('[ApiService] updateOwner (no-mock) called');
    return MockService.updateOwner(owner);
  }

  static Future<bool> deleteOwner(int id) async {
    if (useMock) {
      print('[ApiService] deleteOwner called: id=$id');
      return MockService.deleteOwner(id);
    }
    print('[ApiService] deleteOwner (no-mock) called');
    return MockService.deleteOwner(id);
  }

  // --- Pets (sehr einfache In-Memory Mock-Implementierung) ---
  static final Map<int, List<Pet>> _petsByOwner = {
    1: [
      Pet(id: 1, name: 'Bello', birthDate: DateTime(2018, 5, 20), type: 'dog', ownerId: 1),
    ],
    2: [
      Pet(id: 2, name: 'Lucy', birthDate: DateTime(2016, 3, 12), type: 'cat', ownerId: 2),
    ],
  };

  static int _nextPetId = 3;

  static Future<List<Pet>> getPetsForOwner(int ownerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Pet>.from(_petsByOwner[ownerId] ?? []);
  }

  static Future<List<Pet>> getAllPets() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final all = _petsByOwner.values.expand((list) => list).toList();
    return List<Pet>.from(all);
  }

  static Future<Pet> createPet(Pet pet) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = _nextPetId++;
    final newPet = Pet(id: id, name: pet.name, birthDate: pet.birthDate, type: pet.type, ownerId: pet.ownerId);
    _petsByOwner.putIfAbsent(pet.ownerId, () => []).add(newPet);
    print('[ApiService] createPet: id=$id name=${pet.name} owner=${pet.ownerId}');
    return newPet;
  }

  // Update pet - possibly reassign to another owner
  static Future<Pet> updatePet(Pet pet) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('[ApiService] updatePet called: id=${pet.id} name=${pet.name} owner=${pet.ownerId}');
    // Find and remove from previous owner list
    for (final entry in _petsByOwner.entries) {
      final idx = entry.value.indexWhere((p) => p.id == pet.id);
      if (idx != -1) {
        // if owner changed, remove and add to new owner; else replace
        if (entry.key != pet.ownerId) {
          entry.value.removeAt(idx);
          _petsByOwner.putIfAbsent(pet.ownerId, () => []).add(pet);
        } else {
          entry.value[idx] = pet;
        }
        return pet;
      }
    }
    // Not found: add as new
    _petsByOwner.putIfAbsent(pet.ownerId, () => []).add(pet);
    return pet;
  }

  // --- Vets (static mock list) ---
  static final List<Vet> _vets = [
    Vet(id: 1, firstName: 'James', lastName: 'Carter', specialties: ['dentistry']),
    Vet(id: 2, firstName: 'Helen', lastName: 'Leary', specialties: ['surgery']),
  ];

  static int _nextVetId = 3;

  static Future<List<Vet>> getVets() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Vet>.from(_vets);
  }

  static Future<Vet> createVet(Vet vet) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = _nextVetId++;
    final newVet = Vet(id: id, firstName: vet.firstName, lastName: vet.lastName, specialties: List<String>.from(vet.specialties));
    _vets.add(newVet);
    print('[ApiService] createVet: id=$id name=${vet.firstName} ${vet.lastName}');
    return newVet;
  }

  static Future<Vet> updateVet(Vet vet) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('[ApiService] updateVet called: id=${vet.id} name=${vet.firstName} ${vet.lastName}');
    final idx = _vets.indexWhere((v) => v.id == vet.id);
    if (idx == -1) throw Exception('Vet not found');
    _vets[idx] = vet;
    return vet;
  }

  // --- Visits ---
  static final List<Visit> _visits = [
    Visit(id: 1, petId: 1, vetId: 1, date: DateTime.now().subtract(const Duration(days: 30)), description: 'Annual check'),
  ];
  static int _nextVisitId = 2;

  static Future<List<Visit>> getVisitsForOwner(int ownerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final pets = _petsByOwner[ownerId] ?? [];
    final petIds = pets.map((p) => p.id).toSet();
    return _visits.where((v) => petIds.contains(v.petId)).toList();
  }

  static Future<List<Visit>> getAllVisits() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Visit>.from(_visits);
  }

  static Future<Visit> createVisit(Visit visit) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = _nextVisitId++;
    final newVisit = Visit(id: id, petId: visit.petId, vetId: visit.vetId, date: visit.date, description: visit.description);
    _visits.add(newVisit);
    print('[ApiService] createVisit: id=$id pet=${visit.petId} vet=${visit.vetId} desc=${visit.description}');
    return newVisit;
  }

  static Future<Visit> updateVisit(Visit visit) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('[ApiService] updateVisit called: id=${visit.id} pet=${visit.petId} vet=${visit.vetId}');
    final idx = _visits.indexWhere((v) => v.id == visit.id);
    if (idx == -1) throw Exception('Visit not found');
    _visits[idx] = visit;
    return visit;
  }

  static Future<bool> deleteVisit(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('[ApiService] deleteVisit called: id=$id');
    final initial = _visits.length;
    _visits.removeWhere((v) => v.id == id);
    return _visits.length != initial;
  }

  // Helpers to resolve pet/vet by id
  static Future<Pet?> getPetById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final list in _petsByOwner.values) {
      for (final p in list) {
        if (p.id == id) return p;
      }
    }
    return null;
  }

  static Future<Vet?> getVetById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _vets.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}

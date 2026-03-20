import 'dart:async';
import '../models/owner.dart';
import '../models/pet.dart';
import '../models/vet.dart';
import '../models/visit.dart';

class MockService {
  // Konfigurierbare Standard-Delays (können in Tests verändert werden)
  static Duration defaultFetchDelay = const Duration(milliseconds: 600);
  static Duration defaultOpDelay = const Duration(milliseconds: 300);

  // Interne In-Memory-Liste als Basis für CRUD-Operationen
  static final List<Owner> _owners = [
    Owner(id: 1, firstName: 'Hans', lastName: 'Müller', address: 'Hauptstr. 1', city: 'Wien', telephone: '+43 1 2345678'),
    Owner(id: 2, firstName: 'Anna', lastName: 'Schmidt', address: 'Bahnhofstr. 4', city: 'Graz', telephone: '+43 316 987654'),
    Owner(id: 3, firstName: 'Peter', lastName: 'Meier', address: 'Ringstr. 10', city: 'Salzburg', telephone: '+43 662 555555'),
    Owner(id: 4, firstName: 'Julia', lastName: 'Klein', address: 'Gartenweg 7', city: 'Linz', telephone: '+43 732 444444'),
  ];

  static final Map<int, List<Pet>> _petsByOwner = {
    1: [Pet(id: 1, name: 'Bello', birthDate: DateTime(2018, 5, 20), type: 'dog', ownerId: 1)],
    2: [Pet(id: 2, name: 'Lucy', birthDate: DateTime(2016, 3, 12), type: 'cat', ownerId: 2)],
  };

  static int _nextPetId = 3;

  static final List<Vet> _vets = [
    Vet(id: 1, firstName: 'James', lastName: 'Carter', specialties: ['dentistry']),
    Vet(id: 2, firstName: 'Helen', lastName: 'Leary', specialties: ['surgery']),
  ];
  static int _nextVetId = 3;

  static final List<Visit> _visits = [
    Visit(id: 1, petId: 1, vetId: 1, date: DateTime.now().subtract(const Duration(days: 30)), description: 'Annual check'),
  ];
  static int _nextVisitId = 2;

  static List<Owner> _initialOwners() => [
        Owner(id: 1, firstName: 'Hans', lastName: 'Müller', address: 'Hauptstr. 1', city: 'Wien', telephone: '+43 1 2345678'),
        Owner(id: 2, firstName: 'Anna', lastName: 'Schmidt', address: 'Bahnhofstr. 4', city: 'Graz', telephone: '+43 316 987654'),
        Owner(id: 3, firstName: 'Peter', lastName: 'Meier', address: 'Ringstr. 10', city: 'Salzburg', telephone: '+43 662 555555'),
        Owner(id: 4, firstName: 'Julia', lastName: 'Klein', address: 'Gartenweg 7', city: 'Linz', telephone: '+43 732 444444'),
      ];

  // Reset-Methode für Tests
  static void resetForTests() {
    _owners
      ..clear()
      ..addAll(_initialOwners());
    // Setze Delays zurück
    defaultFetchDelay = const Duration(milliseconds: 600);
    defaultOpDelay = const Duration(milliseconds: 300);

    _petsByOwner
      ..clear()
      ..addAll({
        1: [Pet(id: 1, name: 'Bello', birthDate: DateTime(2018, 5, 20), type: 'dog', ownerId: 1)],
        2: [Pet(id: 2, name: 'Lucy', birthDate: DateTime(2016, 3, 12), type: 'cat', ownerId: 2)],
      });

    _vets
      ..clear()
      ..addAll([
        Vet(id: 1, firstName: 'James', lastName: 'Carter', specialties: ['dentistry']),
        Vet(id: 2, firstName: 'Helen', lastName: 'Leary', specialties: ['surgery']),
      ]);

    _visits
      ..clear()
      ..addAll([
        Visit(id: 1, petId: 1, vetId: 1, date: DateTime.now().subtract(const Duration(days: 30)), description: 'Annual check'),
      ]);

    _nextPetId = 3;
    _nextVetId = 3;
    _nextVisitId = 2;
  }

  // Simuliert einen REST-Call mit Verzögerung
  static Future<List<Owner>> fetchOwners([Duration? delay]) async {
    final d = delay ?? defaultFetchDelay;
    await Future.delayed(d);
    // Gebe eine Kopie zurück, damit externe Änderungen die interne Liste nicht direkt verändern
    return List<Owner>.from(_owners);
  }

  // Fügt einen neuen Owner hinzu und gibt den hinzugefügten Owner mit neuer ID zurück
  static Future<Owner> addOwner(Owner owner, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final nextId = (_owners.isEmpty) ? 1 : (_owners.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1);
    final newOwner = Owner(
      id: nextId,
      firstName: owner.firstName,
      lastName: owner.lastName,
      address: owner.address,
      city: owner.city,
      telephone: owner.telephone,
    );
    _owners.add(newOwner);
    return newOwner;
  }

  // Aktualisiert einen bestehenden Owner; wirf Exception, wenn nicht gefunden
  static Future<Owner> updateOwner(Owner owner, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final idx = _owners.indexWhere((o) => o.id == owner.id);
    if (idx == -1) throw Exception('Owner mit id ${owner.id} nicht gefunden');
    _owners[idx] = owner;
    return owner;
  }

  // Löscht einen Owner nach ID, gibt true zurück wenn gelöscht
  static Future<bool> deleteOwner(int id, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    bool removed = false;
    _owners.removeWhere((o) {
      if (o.id == id) {
        removed = true;
        return true;
      }
      return false;
    });
    return removed;
  }

  // --- Pets Mock ---
  static Future<List<Pet>> getPetsForOwner(int ownerId, [Duration? delay]) async {
    final d = delay ?? defaultFetchDelay;
    await Future.delayed(d);
    return List<Pet>.from(_petsByOwner[ownerId] ?? []);
  }

  static Future<List<Pet>> getAllPets([Duration? delay]) async {
    final d = delay ?? defaultFetchDelay;
    await Future.delayed(d);
    return _petsByOwner.values.expand((l) => l).toList();
  }

  static Future<Pet> addPet(Pet pet, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final id = _nextPetId++;
    final newPet = Pet(id: id, name: pet.name, birthDate: pet.birthDate, type: pet.type, ownerId: pet.ownerId);
    _petsByOwner.putIfAbsent(pet.ownerId, () => []).add(newPet);
    return newPet;
  }

  static Future<Pet> updatePet(Pet pet, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    for (final entry in _petsByOwner.entries) {
      final idx = entry.value.indexWhere((p) => p.id == pet.id);
      if (idx != -1) {
        if (entry.key != pet.ownerId) {
          entry.value.removeAt(idx);
          _petsByOwner.putIfAbsent(pet.ownerId, () => []).add(pet);
        } else {
          entry.value[idx] = pet;
        }
        return pet;
      }
    }
    _petsByOwner.putIfAbsent(pet.ownerId, () => []).add(pet);
    return pet;
  }

  static Future<bool> deletePet(int id, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    bool removed = false;
    _petsByOwner.forEach((key, list) {
      list.removeWhere((p) {
        if (p.id == id) {
          removed = true;
          return true;
        }
        return false;
      });
    });
    return removed;
  }

  static Future<Pet?> getPetById(int id, [Duration? delay]) async {
    final d = delay ?? const Duration(milliseconds: 100);
    await Future.delayed(d);
    for (final list in _petsByOwner.values) {
      for (final p in list) if (p.id == id) return p;
    }
    return null;
  }

  // --- Vets Mock ---
  static Future<List<Vet>> fetchVets([Duration? delay]) async {
    final d = delay ?? defaultFetchDelay;
    await Future.delayed(d);
    return List<Vet>.from(_vets);
  }

  static Future<Vet> addVet(Vet vet, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final id = _nextVetId++;
    final newVet = Vet(id: id, firstName: vet.firstName, lastName: vet.lastName, specialties: List<String>.from(vet.specialties));
    _vets.add(newVet);
    return newVet;
  }

  static Future<Vet> updateVet(Vet vet, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final idx = _vets.indexWhere((v) => v.id == vet.id);
    if (idx == -1) throw Exception('Vet not found');
    _vets[idx] = vet;
    return vet;
  }

  static Future<bool> deleteVet(int id, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final initial = _vets.length;
    _vets.removeWhere((v) => v.id == id);
    return _vets.length != initial;
  }

  static Future<Vet?> getVetById(int id, [Duration? delay]) async {
    final d = delay ?? const Duration(milliseconds: 100);
    await Future.delayed(d);
    try {
      return _vets.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Visits Mock ---
  static Future<List<Visit>> getVisitsForOwner(int ownerId, [Duration? delay]) async {
    final d = delay ?? defaultFetchDelay;
    await Future.delayed(d);
    final pets = _petsByOwner[ownerId] ?? [];
    final petIds = pets.map((p) => p.id).toSet();
    return _visits.where((v) => petIds.contains(v.petId)).toList();
  }

  static Future<List<Visit>> getAllVisits([Duration? delay]) async {
    final d = delay ?? defaultFetchDelay;
    await Future.delayed(d);
    return List<Visit>.from(_visits);
  }

  static Future<Visit> createVisit(Visit visit, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final id = _nextVisitId++;
    final newVisit = Visit(id: id, petId: visit.petId, vetId: visit.vetId, date: visit.date, description: visit.description);
    _visits.add(newVisit);
    return newVisit;
  }

  static Future<Visit> updateVisit(Visit visit, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final idx = _visits.indexWhere((v) => v.id == visit.id);
    if (idx == -1) throw Exception('Visit not found');
    _visits[idx] = visit;
    return visit;
  }

  static Future<bool> deleteVisit(int id, [Duration? delay]) async {
    final d = delay ?? defaultOpDelay;
    await Future.delayed(d);
    final initial = _visits.length;
    _visits.removeWhere((v) => v.id == id);
    return _visits.length != initial;
  }
}

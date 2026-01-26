import 'dart:async';
import '../models/owner.dart';

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
}

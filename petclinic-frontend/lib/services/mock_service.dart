import 'dart:async';
import '../models/owner.dart';

class MockService {
  // Simuliert einen REST-Call mit Verzögerung
  static Future<List<Owner>> fetchOwners([Duration delay = const Duration(milliseconds: 600)]) async {
    await Future.delayed(delay);

    return [
      Owner(id: 1, firstName: 'Hans', lastName: 'Müller', address: 'Hauptstr. 1', city: 'Wien', telephone: '+43 1 2345678'),
      Owner(id: 2, firstName: 'Anna', lastName: 'Schmidt', address: 'Bahnhofstr. 4', city: 'Graz', telephone: '+43 316 987654'),
      Owner(id: 3, firstName: 'Peter', lastName: 'Meier', address: 'Ringstr. 10', city: 'Salzburg', telephone: '+43 662 555555'),
      Owner(id: 4, firstName: 'Julia', lastName: 'Klein', address: 'Gartenweg 7', city: 'Linz', telephone: '+43 732 444444'),
    ];
  }
}


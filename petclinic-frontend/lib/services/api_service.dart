import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:wmcdbi_petclinic_frontend/models/pet.dart';
import 'package:wmcdbi_petclinic_frontend/models/vet.dart';
import 'package:wmcdbi_petclinic_frontend/models/visit.dart';
import 'package:wmcdbi_petclinic_frontend/models/owner.dart';
import 'mock_service.dart';

// ApiService: verwendet standardmäßig HTTP-Requests gegen das Backend.
// Falls `useMock == true`, wird die vorhandene Mock-Implementierung verwendet (nützlich für Entwicklung ohne Backend).
class ApiService {
  // Wenn true -> MockService verwenden; wenn false -> echte HTTP-Requests
  static bool useMock = false; // <-- geändert: nicht mehr lokal (Mock) als default

  // Basis-URL des Backends (kann per --dart-define oder Programmatisch angepasst werden)
  static String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  static Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  // Helper zum Parsen einer möglichen paged response
  static List<T> _extractList<T>(dynamic data, T Function(Map<String, dynamic>) mapper) {
    if (data == null) return [];
    if (data is List) return data.map((e) => mapper(e as Map<String, dynamic>)).toList();
    if (data is Map && data['content'] is List) return (data['content'] as List).map((e) => mapper(e as Map<String, dynamic>)).toList();
    return [];
  }

  // --- Owners ---
  static Future<List<Owner>> getOwners({String? q, String? city}) async {
    if (useMock) return MockService.fetchOwners();
    final uri = Uri.parse('$baseUrl/api/owners').replace(queryParameters: {
      if (q != null && q.isNotEmpty) 'q': q,
      if (city != null && city.isNotEmpty) 'city': city,
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return _extractList<Owner>(data, (m) => Owner.fromJson(m));
    }
    throw Exception('getOwners failed: ${res.statusCode} ${res.body}');
  }

  static Future<Owner> getOwner(int id, {bool includePets = false}) async {
    if (useMock) return MockService.fetchOwners().then((l) => l.firstWhere((o) => o.id == id));
    final uri = Uri.parse('$baseUrl/api/owners/$id').replace(queryParameters: {
      if (includePets) 'includePets': 'true',
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) return Owner.fromJson(json.decode(res.body));
    throw Exception('getOwner $id failed: ${res.statusCode} ${res.body}');
  }

  static Future<Owner> createOwner(Owner owner) async {
    if (useMock) return MockService.addOwner(owner);
    final uri = Uri.parse('$baseUrl/api/owners');
    final body = Map<String, dynamic>.from(owner.toJson());
    // remove id for create if 0
    if (body['id'] == 0) body.remove('id');
    final res = await http.post(uri, headers: _jsonHeaders, body: json.encode(body));
    if (res.statusCode == 200 || res.statusCode == 201) return Owner.fromJson(json.decode(res.body));
    throw Exception('createOwner failed: ${res.statusCode} ${res.body}');
  }

  static Future<Owner> updateOwner(Owner owner) async {
    if (useMock) return MockService.updateOwner(owner);
    final uri = Uri.parse('$baseUrl/api/owners/${owner.id}');
    final body = Map<String, dynamic>.from(owner.toJson());
    body.remove('id');
    final res = await http.put(uri, headers: _jsonHeaders, body: json.encode(body));
    if (res.statusCode == 200) return Owner.fromJson(json.decode(res.body));
    throw Exception('updateOwner failed: ${res.statusCode} ${res.body}');
  }

  static Future<bool> deleteOwner(int id) async {
    if (useMock) return MockService.deleteOwner(id);
    final uri = Uri.parse('$baseUrl/api/owners/$id');
    final res = await http.delete(uri);
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // --- Pets ---
  static Future<List<Pet>> getPetsForOwner(int ownerId) async {
    if (useMock) return MockService.getPetsForOwner(ownerId);
    final uri = Uri.parse('$baseUrl/api/pets/owners/$ownerId/pets');
    final res = await http.get(uri);
    if (res.statusCode == 200) return _extractList<Pet>(json.decode(res.body), (m) => Pet.fromJson(m));
    throw Exception('getPetsForOwner failed: ${res.statusCode} ${res.body}');
  }

  static Future<List<Pet>> getAllPets() async {
    if (useMock) return MockService.getAllPets();
    final uri = Uri.parse('$baseUrl/api/pets');
    final res = await http.get(uri);
    if (res.statusCode == 200) return _extractList<Pet>(json.decode(res.body), (m) => Pet.fromJson(m));
    throw Exception('getAllPets failed: ${res.statusCode} ${res.body}');
  }

  static Future<Pet> createPet(Pet pet) async {
    if (useMock) return _createPetMock(pet);
    final uri = Uri.parse('$baseUrl/api/pets');
    final body = Map<String, dynamic>.from(pet.toJson());
    if (body['id'] == 0) body.remove('id');
    final res = await http.post(uri, headers: _jsonHeaders, body: json.encode(body));
    if (res.statusCode == 200 || res.statusCode == 201) return Pet.fromJson(json.decode(res.body));
    throw Exception('createPet failed: ${res.statusCode} ${res.body}');
  }

  static Future<Pet> updatePet(Pet pet) async {
    if (useMock) return MockService.updatePet(pet);
    final uri = Uri.parse('$baseUrl/api/pets/${pet.id}');
    final body = Map<String, dynamic>.from(pet.toJson());
    body.remove('id');
    final res = await http.put(uri, headers: _jsonHeaders, body: json.encode(body));
    if (res.statusCode == 200) return Pet.fromJson(json.decode(res.body));
    throw Exception('updatePet failed: ${res.statusCode} ${res.body}');
  }

  static Future<bool> deletePet(int id) async {
    if (useMock) return MockService.deletePet(id);
    final uri = Uri.parse('$baseUrl/api/pets/$id');
    final res = await http.delete(uri);
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // --- Vets ---
  static Future<List<Vet>> getVets() async {
    if (useMock) return MockService.fetchVets();
    final uri = Uri.parse('$baseUrl/api/vets').replace(queryParameters: {'arg0': '0,100'});
    final res = await http.get(uri);
    if (res.statusCode == 200) return _extractList<Vet>(json.decode(res.body), (m) => Vet.fromJson(m));
    throw Exception('getVets failed: ${res.statusCode} ${res.body}');
  }

  static Future<Vet> createVet(Vet vet) async {
    if (useMock) return MockService.addVet(vet);
    final uri = Uri.parse('$baseUrl/api/vets');
    final res = await http.post(uri, headers: _jsonHeaders, body: json.encode(vet.toJson()));
    if (res.statusCode == 200 || res.statusCode == 201) return Vet.fromJson(json.decode(res.body));
    throw Exception('createVet failed: ${res.statusCode} ${res.body}');
  }

  static Future<Vet> updateVet(Vet vet) async {
    if (useMock) return MockService.updateVet(vet);
    final uri = Uri.parse('$baseUrl/api/vets/${vet.id}');
    final res = await http.put(uri, headers: _jsonHeaders, body: json.encode(vet.toJson()));
    if (res.statusCode == 200) return Vet.fromJson(json.decode(res.body));
    throw Exception('updateVet failed: ${res.statusCode} ${res.body}');
  }

  static Future<bool> deleteVet(int id) async {
    if (useMock) return MockService.deleteVet(id);
    final uri = Uri.parse('$baseUrl/api/vets/$id');
    final res = await http.delete(uri);
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // --- Visits ---
  static Future<List<Visit>> getVisitsForOwner(int ownerId) async {
    if (useMock) return MockService.getVisitsForOwner(ownerId);
    final uri = Uri.parse('$baseUrl/api/visits/owners/$ownerId/visits');
    final res = await http.get(uri);
    if (res.statusCode == 200) return _extractList<Visit>(json.decode(res.body), (m) => Visit.fromJson(m));
    throw Exception('getVisitsForOwner failed: ${res.statusCode} ${res.body}');
  }

  static Future<List<Visit>> getAllVisits() async {
    if (useMock) return MockService.getAllVisits();
    final uri = Uri.parse('$baseUrl/api/visits').replace(queryParameters: {'arg2': '0,100'});
    final res = await http.get(uri);
    if (res.statusCode == 200) return _extractList<Visit>(json.decode(res.body), (m) => Visit.fromJson(m));
    throw Exception('getAllVisits failed: ${res.statusCode} ${res.body}');
  }

  static Future<Visit> createVisit(Visit visit) async {
    if (useMock) return MockService.createVisit(visit);
    final uri = Uri.parse('$baseUrl/api/visits');
    final body = visit.toJson();
    if (body['id'] == 0) body.remove('id');
    final res = await http.post(uri, headers: _jsonHeaders, body: json.encode(body));
    if (res.statusCode == 200 || res.statusCode == 201) return Visit.fromJson(json.decode(res.body));
    throw Exception('createVisit failed: ${res.statusCode} ${res.body}');
  }

  static Future<Visit> updateVisit(Visit visit) async {
    if (useMock) return MockService.updateVisit(visit);
    final uri = Uri.parse('$baseUrl/api/visits/${visit.id}');
    final body = visit.toJson();
    body.remove('id');
    final res = await http.put(uri, headers: _jsonHeaders, body: json.encode(body));
    if (res.statusCode == 200) return Visit.fromJson(json.decode(res.body));
    throw Exception('updateVisit failed: ${res.statusCode} ${res.body}');
  }

  static Future<bool> deleteVisit(int id) async {
    if (useMock) return MockService.deleteVisit(id);
    final uri = Uri.parse('$baseUrl/api/visits/$id');
    final res = await http.delete(uri);
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // Helpers (mock fallbacks kept)
  static Future<Pet?> getPetById(int id) async {
    if (useMock) return MockService.getPetById(id);
    final uri = Uri.parse('$baseUrl/api/pets/$id');
    final res = await http.get(uri);
    if (res.statusCode == 200) return Pet.fromJson(json.decode(res.body));
    return null;
  }

  static Future<Vet?> getVetById(int id) async {
    if (useMock) return MockService.getVetById(id);
    final uri = Uri.parse('$baseUrl/api/vets/$id');
    final res = await http.get(uri);
    if (res.statusCode == 200) return Vet.fromJson(json.decode(res.body));
    return null;
  }

  // Internal helper to keep older mock createPet behaviour when useMock==true
  static Future<Pet> _createPetMock(Pet pet) async => MockService.addPet(pet);
}

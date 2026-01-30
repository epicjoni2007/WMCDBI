import 'package:flutter_test/flutter_test.dart';
import 'package:wmcdbi_petclinic_frontend/services/api_service.dart';
import 'package:wmcdbi_petclinic_frontend/models/pet.dart';
import 'package:wmcdbi_petclinic_frontend/models/visit.dart';

void main() {
  test('ApiService create/update pet and visit', () async {
    ApiService.useMock = true;
    final pet = await ApiService.createPet(Pet(id: 0, name: 'SmokePet', birthDate: DateTime(2020), type: 'dog', ownerId: 1));
    print('TEST: created pet id=${pet.id} name=${pet.name} owner=${pet.ownerId}');

    final updated = Pet(id: pet.id, name: 'SmokePet2', birthDate: pet.birthDate, type: pet.type, ownerId: pet.ownerId);
    final up = await ApiService.updatePet(updated);
    print('TEST: updated pet id=${up.id} name=${up.name}');

    final visit = await ApiService.createVisit(Visit(id: 0, petId: pet.id, vetId: 1, date: DateTime.now(), description: 'Smoke visit'));
    print('TEST: created visit id=${visit.id} pet=${visit.petId}');

    final vup = await ApiService.updateVisit(Visit(id: visit.id, petId: visit.petId, vetId: visit.vetId, date: visit.date, description: 'Smoke visit updated'));
    print('TEST: updated visit id=${vup.id} desc=${vup.description}');

    expect(up.name, 'SmokePet2');
    expect(vup.description, 'Smoke visit updated');
  });
}

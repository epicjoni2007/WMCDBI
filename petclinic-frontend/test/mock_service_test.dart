import 'package:flutter_test/flutter_test.dart';
import 'package:wmcdbi_petclinic_frontend/services/mock_service.dart';
import 'package:wmcdbi_petclinic_frontend/models/owner.dart';

void main() {
  test('fetchOwners returns 4 owners and correct first owner', () async {
    final List<Owner> owners = await MockService.fetchOwners(Duration.zero);

    expect(owners, isA<List<Owner>>());
    expect(owners.length, 4);
    expect(owners[0].fullName, 'Hans Müller');
  });
}


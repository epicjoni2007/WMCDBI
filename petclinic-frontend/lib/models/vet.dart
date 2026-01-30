class Vet {
  final int id;
  final String firstName;
  final String lastName;
  final List<String> specialties;

  Vet({required this.id, required this.firstName, required this.lastName, required this.specialties});

  factory Vet.fromJson(Map<String, dynamic> json) => Vet(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        specialties: (json['specialties'] as List<dynamic>).map((e) => e as String).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'specialties': specialties,
      };
}

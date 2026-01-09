class Owner {
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String city;
  final String telephone;

  Owner({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.city,
    required this.telephone,
  });

  String get fullName => '$firstName $lastName';

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        address: json['address'] as String,
        city: json['city'] as String,
        telephone: json['telephone'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'city': city,
        'telephone': telephone,
      };
}


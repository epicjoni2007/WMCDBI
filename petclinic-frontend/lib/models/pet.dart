class Pet {
  final int id;
  final String name;
  final DateTime birthDate;
  final String type;
  final int ownerId;

  Pet({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.type,
    required this.ownerId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: json['id'] as int,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        type: json['type'] as String,
        ownerId: json['ownerId'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'type': type,
        'ownerId': ownerId,
      };
}

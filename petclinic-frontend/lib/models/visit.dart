class Visit {
  final int id;
  final int petId;
  final int? vetId;
  final DateTime date;
  final String description;

  Visit({required this.id, required this.petId, this.vetId, required this.date, required this.description});

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
        id: json['id'] as int,
        petId: json['petId'] as int,
        vetId: json['vetId'] == null ? null : (json['vetId'] as int),
        date: DateTime.parse(json['date'] as String),
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'vetId': vetId,
        'date': date.toIso8601String(),
        'description': description,
      };
}

class Person {
  final String id;
  final String userId;
  final String name;
  final int? age;
  final String? howKnown;
  final DateTime createdAt;
  final int dateCount; // Count of dates with this person

  const Person({
    required this.id,
    required this.userId,
    required this.name,
    this.age,
    this.howKnown,
    required this.createdAt,
    this.dateCount = 0,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    // Handling Supabase count aggregation which comes as a list/object depending on query
    // usually: { ..., "dates": [{"count": 5}] } if using select('*, dates(count)')
    int count = 0;
    if (json['dates'] != null) {
      if (json['dates'] is List && (json['dates'] as List).isNotEmpty) {
        final first = (json['dates'] as List).first;
        if (first is Map && first.containsKey('count')) {
          count = first['count'] as int;
        }
      } else if (json['dates'] is Map &&
          (json['dates'] as Map).containsKey('count')) {
        // Sometimes it might come as object? usually list for relation count
        count = json['dates']['count'] as int;
      }
    }

    return Person(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      age: json['age'] as int?,
      howKnown: json['how_known'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      dateCount: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'age': age,
      'how_known': howKnown,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

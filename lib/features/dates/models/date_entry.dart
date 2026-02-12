import 'package:date_journal_app/features/persons/models/person.dart';

class DateEntry {
  final String id;
  final String userId;
  final String? personId;
  final Person? person;
  final DateTime dateTime;
  final String location;
  final String? manStyle;
  final int ratingChemistry;
  final int ratingConversation;
  final int ratingPunctuality;
  final int ratingAppearance;
  final double ratingOverall;
  final String? whatWeDid;
  final String? hisBehavior;
  final String? awkwardMoments;
  final String? funnyMoments;
  final String? greenFlags;
  final String? redFlags;
  final String? myNotes;
  final String? mood;
  final String? highlights;
  final String? dateType;
  final bool spentNightTogether;
  final DateTime createdAt;

  const DateEntry({
    required this.id,
    required this.userId,
    this.personId,
    this.person,
    required this.dateTime,
    required this.location,
    this.manStyle,
    required this.ratingChemistry,
    required this.ratingConversation,
    required this.ratingPunctuality,
    required this.ratingAppearance,
    required this.ratingOverall,
    this.whatWeDid,
    this.hisBehavior,
    this.awkwardMoments,
    this.funnyMoments,
    this.greenFlags,
    this.redFlags,
    this.myNotes,
    this.mood,
    this.highlights,
    this.dateType,
    required this.spentNightTogether,
    required this.createdAt,
  });

  factory DateEntry.fromJson(Map<String, dynamic> json) {
    Person? person;
    if (json['persons'] != null) {
      person = Person.fromJson(json['persons']);
    }

    return DateEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      personId: json['person_id'] as String?,
      person: person,
      dateTime: DateTime.parse(json['date_time'] as String),
      location: json['location'] as String? ?? '',
      manStyle: json['man_style'] as String?,
      ratingChemistry: json['rating_chemistry'] as int? ?? 0,
      ratingConversation: json['rating_conversation'] as int? ?? 0,
      ratingPunctuality: json['rating_punctuality'] as int? ?? 0,
      ratingAppearance: json['rating_appearance'] as int? ?? 0,
      ratingOverall: (json['rating_overall'] as num?)?.toDouble() ?? 0.0,
      whatWeDid: json['what_we_did'] as String?,
      hisBehavior: json['his_behavior'] as String?,
      awkwardMoments: json['awkward_moments'] as String?,
      funnyMoments: json['funny_moments'] as String?,
      greenFlags: json['green_flags'] as String?,
      redFlags: json['red_flags'] as String?,
      myNotes: json['my_notes'] as String?,
      mood: json['mood'] as String?,
      highlights: json['highlights'] as String?,
      dateType: json['date_type'] as String?,
      spentNightTogether: json['spent_night_together'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'person_id': personId,
      'date_time': dateTime.toIso8601String(),
      'location': location,
      'man_style': manStyle,
      'rating_chemistry': ratingChemistry,
      'rating_conversation': ratingConversation,
      'rating_punctuality': ratingPunctuality,
      'rating_appearance': ratingAppearance,
      'rating_overall': ratingOverall,
      'what_we_did': whatWeDid,
      'his_behavior': hisBehavior,
      'awkward_moments': awkwardMoments,
      'funny_moments': funnyMoments,
      'green_flags': greenFlags,
      'red_flags': redFlags,
      'my_notes': myNotes,
      'mood': mood,
      'highlights': highlights,
      'date_type': dateType,
      'spent_night_together': spentNightTogether,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

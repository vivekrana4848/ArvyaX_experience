/// Immutable data model for a journal entry persisted in SQLite.
class JournalEntryModel {
  final int? id;
  final String text;
  final String mood;
  final String? ambienceTitle;
  final DateTime createdAt;

  const JournalEntryModel({
    this.id,
    required this.text,
    required this.mood,
    this.ambienceTitle,
    required this.createdAt,
  });

  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    return JournalEntryModel(
      id: map['id'] as int?,
      text: map['text'] as String,
      mood: map['mood'] as String,
      ambienceTitle: map['ambience_title'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'text': text,
        'mood': mood,
        'ambience_title': ambienceTitle,
        'created_at': createdAt.toIso8601String(),
      };

  JournalEntryModel copyWith({
    int? id,
    String? text,
    String? mood,
    String? ambienceTitle,
    DateTime? createdAt,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      text: text ?? this.text,
      mood: mood ?? this.mood,
      ambienceTitle: ambienceTitle ?? this.ambienceTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is JournalEntryModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

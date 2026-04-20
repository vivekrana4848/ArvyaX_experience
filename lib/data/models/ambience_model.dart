import 'dart:convert';

/// Immutable data model for an ambience item loaded from JSON.
class AmbienceModel {
  final String id;
  final String title;
  final String tag;
  final int duration; // seconds
  final String description;
  final String audioAsset;
  final String imageAsset;
  final List<String> sensoryChips;
  final int bpm;

  const AmbienceModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.duration,
    required this.description,
    required this.audioAsset,
    required this.imageAsset,
    required this.sensoryChips,
    required this.bpm,
  });

  factory AmbienceModel.fromJson(Map<String, dynamic> json) {
    return AmbienceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      duration: json['duration'] as int,
      description: json['description'] as String,
      audioAsset: json['audioAsset'] as String,
      imageAsset: json['imageAsset'] as String,
      sensoryChips: List<String>.from(json['sensoryChips'] as List),
      bpm: json['bpm'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'tag': tag,
        'duration': duration,
        'description': description,
        'audioAsset': audioAsset,
        'imageAsset': imageAsset,
        'sensoryChips': jsonEncode(sensoryChips),
        'bpm': bpm,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AmbienceModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

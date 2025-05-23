import 'package:iks/model/survey/section.dart';

class Survey {
  final String id;
  final String title;
  final String? description;
  final List<Section> sections;

  Survey({
    required this.id,
    required this.title,
    this.description,
    required this.sections,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sections:
          (json['sections'] as List).map((s) => Section.fromJson(s)).toList(),
    );
  }
}
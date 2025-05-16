import 'package:iks/model/survey/question.dart';

class Section {
  final String id;
  final String title;
  final String? description;
  final List<Question> questions;

  Section({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
    );
  }
}

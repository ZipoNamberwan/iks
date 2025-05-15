import 'package:iks/model/survey/question_type.dart';
import 'package:iks/model/survey/validation.dart';

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

class Question {
  final String id;
  final String text;
  final String? hint;
  final QuestionType type;
  final List<Option>? options;
  final List<ValidationRule>? validationRules;
  final bool allowMultiple; // For checkbox type
  final dynamic defaultValue;

  Question({
    required this.id,
    required this.text,
    this.hint,
    required this.type,
    this.options,
    this.validationRules,
    this.allowMultiple = false,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'hint': hint,
      'type': type.toString(),
      'options': options?.map((o) => o.toJson()).toList(),
      'validationRules': validationRules?.map((v) => v.toJson()).toList(),
      'allowMultiple': allowMultiple,
      'defaultValue': defaultValue,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      hint: json['hint'],
      type: QuestionType.values.firstWhere((e) => e.toString() == json['type'],
          orElse: () => QuestionType.text),
      options: json['options'] != null
          ? (json['options'] as List).map((o) => Option.fromJson(o)).toList()
          : null,
      validationRules: json['validationRules'] != null
          ? (json['validationRules'] as List)
              .map((v) => ValidationRule.fromJson(v))
              .toList()
          : null,
      allowMultiple: json['allowMultiple'] ?? false,
      defaultValue: json['defaultValue'],
    );
  }
}

class Option {
  final String id;
  final String label;
  final dynamic value;

  Option({
    required this.id,
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
    };
  }

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      label: json['label'],
      value: json['value'],
    );
  }
}
